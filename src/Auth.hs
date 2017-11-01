{-# LANGUAGE OverloadedStrings #-}
module Auth where

import WebToken
import Hetzer

import qualified User as U

import qualified System.IO.Streams as Streams
import qualified Data.ByteString.Builder as Builder
import qualified Data.ByteString.Lazy as BS
import qualified Data.List as L
import qualified Data.ByteString.Char8 as C

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
import Database.Redis
import Data.Bool

forbidden :: Response
forbidden = setResponseCode 403 emptyResponse

statusOK :: Response
statusOK = setResponseCode 200 emptyResponse

finishWithForbidden :: MonadSnap m => m a
finishWithForbidden = finishWith response
    where response = setResponseCode 403 emptyResponse

finishWithForbidden' :: MonadSnap m => ByteString -> m a
finishWithForbidden' message = finishWith $ setResponseCode 403 $ setResponseBody body emptyResponse
    where body = (\out -> do
                    Streams.write (Just $ Builder.byteString message) out
                    return out
                    )

finishWithResponseWithToken :: MonadSnap m => Response -> JWK -> UUID -> m a
finishWithResponseWithToken r jwk uuid = do
    salt <- liftIO $ randomIO
    payload <- return $ TokenPayload uuid salt
    token <- liftIO $ doJwsSign jwk payload
    case token of
        Left e -> finishWithForbidden
        Right t -> finishWith $ setResponseCode 200 $ setHeader "x-auth-token" (BS.toStrict $ encode t) r

finishWithResponseWithToken' :: MonadSnap m => JWK -> UUID -> m a
finishWithResponseWithToken' = finishWithResponseWithToken emptyResponse

responseWithToken :: Response -> JWK -> UUID -> IO (Response, Maybe TokenPayload)
responseWithToken r jwk uuid = do
    salt <- liftIO $ randomIO
    payload <- return $ TokenPayload uuid salt
    token <- doJwsSign jwk payload
    case token of
        Left e -> return (forbidden, Nothing)
        Right t -> return (setResponseCode 200 $ setHeader "x-auth-token" (BS.toStrict $ encode t) r, Just payload)

responseWithToken' :: JWK -> UUID -> IO (Response, Maybe TokenPayload)
responseWithToken' = responseWithToken emptyResponse

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
                    redis_cn <- gets _redis_connection
                    auth <- liftIO $ doJwsVerify jwk (BS.fromStrict $ L.last hd)
                    case auth of
                        Left s -> finishWithForbidden' "wrong token"
                        Right t -> do
                            session <- liftIO $ checkUserSession redis_cn t
                            case session of
                                False -> do
                                    liftIO $ removeExpiredKey redis_cn (user_id t)
                                    finishWithForbidden' "Session expired"
                                True -> do
                                    putRequest request
                                    handler
                                    r <- getResponse
                                    rwt <- liftIO $ responseWithToken r jwk (user_id t)
                                    case rwt of
                                        (response, Just token) -> do
                                            liftIO $ registerUserSession redis_cn token
                                            finishWith response
                                        (response, Nothing) -> finishWith response

registerUserSession :: Connection -> TokenPayload -> IO (Either Reply Bool)
registerUserSession cn token = do
    runRedis cn $ do
        key <- return $ C.pack $ Data.UUID.toString $ user_id token
        Database.Redis.set key (C.pack $ show $ salt token)
        expire key 600

removeExpiredKey :: Connection -> UUID -> IO (Either Reply Integer)
removeExpiredKey cn uuid = runRedis cn $ del [C.pack $ Data.UUID.toString uuid]

checkUserSession :: Connection -> TokenPayload -> IO Bool
checkUserSession cn token = do
    result <- (runRedis cn $ do
                key <- return $ C.pack $ Data.UUID.toString $ user_id token
                Database.Redis.get key)
    case result of
        Left e -> return False
        Right r -> do
            case r of
                Nothing -> return False
                Just v -> return $ ((read :: String -> Int) $ C.unpack v) == (salt token)

