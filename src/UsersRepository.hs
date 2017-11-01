{-# LANGUAGE OverloadedStrings #-}
module UsersRepository(handlers) where

import User
import MongoDBAction
import UUIDconverter
import Hetzer
import UserConverter

import qualified Database.MongoDB as DB
import qualified Data.ByteString.Lazy as BS
import qualified Data.ByteString.Char8 as C

import Data.Aeson
import System.Random
import Snap.Core
import Snap.Util.FileServe
import Snap.Http.Server
import Snap.Snaplet
import Control.Monad.Trans (liftIO)
import Control.Monad.IO.Class
import Data.Maybe
import Data.ByteString
import Data.List
import Crypto.BCrypt

handlers :: [(ByteString, Handler Hetzer Hetzer ())]
handlers = [
            ("users", method POST addNewUser),
            ("users", method GET getUsers),
            ("users/:userId", method GET getUser)
        ]

addNewUser :: Handler Hetzer Hetzer ()
addNewUser = do
    body <- readRequestBody 2048
    user <- return $ (decode :: BS.ByteString -> Maybe User) body
    maybe (writeBS "unable to parse JSON") insertUser user

insertUser :: User -> Handler Hetzer Hetzer ()
insertUser user = do
    uuid <- liftIO $ randomIO
    encryptedPasswd <- liftIO $ hashPasswordUsingPolicy fastBcryptHashingPolicy (C.pack $ fromMaybe "" $ password user)
    case encryptedPasswd of
        Nothing -> return ()
        Just p -> do
            performAction $ DB.insert "users" $ userToDocument $ user {User.id = Just uuid, User.password = (fmap C.unpack $ Just p)}
            return ()

getUser :: Handler Hetzer Hetzer ()
getUser = do
    param <- getParam "userId"
    loadUser param

loadUser :: Maybe ByteString -> Handler Hetzer Hetzer ()
loadUser (Just param) = do
    document <- performAction $ (DB.find (DB.select ["_id" DB.=: DB.UUID param] "users") >>= DB.rest)
    returnDocument document
loadUser Nothing = writeBS "userId is not specified"

returnDocument :: [DB.Document] -> Handler Hetzer Hetzer ()
returnDocument (a:ax) = writeLBS $ encode $ (userFromDocument a) {User.password = Nothing}
returnDocument [] = writeBS "user does not exist"

getUsers :: Handler Hetzer Hetzer ()
getUsers = do
    documents <- performAction $ (DB.find (DB.select [] "users") >>= DB.rest)
    writeLBS $ encode $ liftToJSON toJSON toJSON $ Data.List.map (hideUsersPassword . userFromDocument) documents

hideUsersPassword :: User -> User
hideUsersPassword user = user {User.password = Nothing}
