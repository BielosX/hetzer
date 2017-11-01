{-# LANGUAGE OverloadedStrings #-}
module Auth where

import WebToken

import qualified User as U

import qualified System.IO.Streams as Streams
import qualified Data.ByteString.Builder as Builder
import qualified Data.ByteString.Lazy as BS

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

finishWithForbidden :: MonadSnap m => m a
finishWithForbidden = finishWith response
    where response = setResponseCode 403 emptyResponse

finishWithForbidden' :: MonadSnap m => ByteString -> m a
finishWithForbidden' message = finishWith $ setResponseCode 403 $ setResponseBody body emptyResponse
    where body = (\out -> do
                    Streams.write (Just $ Builder.byteString message) out
                    return out
                    )

finishWithresponseWithToken :: MonadSnap m => JWK -> U.User -> m a
finishWithresponseWithToken jwk user = do
    salt <- liftIO $ randomIO
    payload <- return $ TokenPayload (fromJust $ U.id user) salt
    token <- liftIO $ doJwsSign jwk payload
    case token of
        Left e -> finishWithForbidden
        Right t -> finishWith $ setResponseCode 200 $ setHeader "x-auth-token" (BS.toStrict $ encode t) emptyResponse

