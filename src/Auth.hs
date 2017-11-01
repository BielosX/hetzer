{-# LANGUAGE OverloadedStrings #-}
module Auth where

import WebToken
import Hetzer

import qualified User as U

import qualified System.IO.Streams as Streams
import qualified Data.ByteString.Builder as Builder
import qualified Data.ByteString.Lazy as BS
import qualified Data.List as L

import Snap.Core
import Snap.Util.FileServe
import Snap.Http.Server
import Snap.Snaplet
import System.Random
import Data.ByteString
import Crypto.JOSE.JWS
import Crypto.JOSE.JWK
import Crypto.JOSE.Error
import Data.Maybe
import Control.Monad.Trans (liftIO)
import Data.Aeson
import Control.Monad.State
import Data.UUID
import Data.ByteString.Internal (c2w)

finishWithForbidden :: MonadSnap m => m a
finishWithForbidden = finishWith response
    where response = setResponseCode 403 emptyResponse

finishWithForbidden' :: MonadSnap m => ByteString -> m a
finishWithForbidden' message = finishWith $ setResponseCode 403 $ setResponseBody body emptyResponse
    where body = (\out -> do
                    Streams.write (Just $ Builder.byteString message) out
                    return out
                    )

finishWithresponseWithToken :: MonadSnap m => Response -> JWK -> UUID -> m a
finishWithresponseWithToken r jwk uuid = do
    salt <- liftIO $ randomIO
    payload <- return $ TokenPayload uuid salt
    token <- liftIO $ doJwsSign jwk payload
    case token of
        Left e -> finishWithForbidden
        Right t -> finishWith $ setResponseCode 200 $ setHeader "x-auth-token" (BS.toStrict $ encode t) r

finishWithresponseWithToken' :: MonadSnap m => JWK -> UUID -> m a
finishWithresponseWithToken' = finishWithresponseWithToken emptyResponse

authorize :: Handler Hetzer Hetzer () -> Handler Hetzer Hetzer ()
authorize handler = do
    request <- getRequest
    header <- return $ getHeader "Authorization" request
    case header of
        Nothing -> finishWithForbidden' "no Authorization header"
        Just h -> do
            hd <-  return $ Data.ByteString.split (c2w ' ') h
            case (L.length hd == 2 && L.head hd == "Bearer") of
                False -> finishWithForbidden' "wrong Authorization header"
                True -> do
                    jwk <- gets _jwk
                    auth <- liftIO $ doJwsVerify jwk (BS.fromStrict $ L.last hd)
                    case auth of
                        Left s -> finishWithForbidden' "wrong token"
                        Right t -> do
                            putRequest request
                            handler
                            r <- getResponse
                            finishWithresponseWithToken r jwk (user_id t)
