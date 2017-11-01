{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
module LogIn(handlers) where
import Hetzer
import UserPasswd
import MongoDBAction
import UserConverter
import WebToken
import Auth

import qualified Database.MongoDB as DB
import qualified Data.ByteString.Lazy as BS
import qualified Data.ByteString.Char8 as C
import qualified User as U
import qualified Data.Typeable as Typeable

import Crypto.JOSE.JWS
import Control.Monad.State
import Crypto.JOSE.JWK
import Crypto.JOSE.Error
import GHC.Generics
import Data.ByteString
import Data.Aeson
import Snap.Core
import Snap.Util.FileServe
import Snap.Http.Server
import Snap.Snaplet
import Control.Monad.Trans (liftIO, MonadIO)
import Crypto.BCrypt
import Data.Maybe
import System.Random
import Data.Either

data LoginPayload = LoginPayload {
                                    username :: String,
                                    password :: String
                                } deriving (Show, Generic)

instance FromJSON LoginPayload where
instance ToJSON LoginPayload where

handlers :: [(ByteString, Handler Hetzer Hetzer ())]
handlers = [("login", method POST logIn)]

logIn :: Handler Hetzer Hetzer ()
logIn = do
    body <- readRequestBody 2048
    payload <- return $ (decode :: BS.ByteString -> Maybe LoginPayload) body
    case payload of
        Nothing -> finishWithForbidden' "unable to parse payload"
        Just p -> do
            document <- performAction $ (DB.find (DB.select ["name" DB.=: (username p)] "users") >>= DB.next)
            case document of
                Nothing -> finishWithForbidden' "unable to fetch user"
                Just d -> do
                    user <- return $ userFromDocument d
                    case (validatePassword (C.pack $ fromJust $ U.password user) (C.pack $ password p)) of
                        True -> do
                            jwk <- gets _jwk
                            finishWithresponseWithToken jwk user
                        False -> finishWithForbidden' "wrong password"

