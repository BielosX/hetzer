{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Applicative
import Snap.Core
import Snap.Util.FileServe
import Snap.Http.Server
import Snap.Snaplet
import User
import qualified Database.MongoDB as DB
import Control.Monad.Trans (liftIO)
import Control.Monad.IO.Class
import Data.ByteString
import Data.Aeson
import Data.Text.Encoding
import Data.Maybe
import Data.UUID
import System.Random
import Data.List
import Control.Applicative
import Control.Monad

data DatabaseConfig = DatabaseConfig {
    databse_addr :: String,
    database_name :: String
}

data Hetzer = Hetzer {
    database_conf :: DatabaseConfig
}

getDatabase :: DB.Database
getDatabase = "my_database"

getAccessMode :: DB.AccessMode
getAccessMode = DB.master

getDatabaseAddr = "0.0.0.0"

performAction action = do
    pipe <- DB.connect $ DB.host $ getDatabaseAddr
    result <- DB.access pipe getAccessMode getDatabase action
    DB.close pipe
    return result

handlers = [
            ("/", writeBS "Hetzer"),
            ("users", method POST addNewUser),
            ("users", method GET getUsers),
            ("users/:userId", method GET getUser)
          ]

addNewUser :: Handler Hetzer Hetzer ()
addNewUser = do
    body <- readRequestBody 2048
    user <- return (decode body)
    maybe (writeBS "unable to parse JSON") insertUser user

insertUser user = do
    uuid <- liftIO $ randomIO
    liftIO $ performAction $ DB.insert "users" $ userToDocument $ user {User.id = Just uuid}
    return ()

getUser :: Handler Hetzer Hetzer ()
getUser = do
    param <- getParam "userId"
    loadUser param

loadUser :: Maybe ByteString -> Handler Hetzer Hetzer ()
loadUser (Just param) = do
    document <- liftIO $ performAction $ (DB.find (DB.select ["_id" DB.=: DB.UUID param] "users") >>= DB.rest)
    returnDocument document
loadUser Nothing = writeBS "userId is not specified"

returnDocument :: [DB.Document] -> Handler Hetzer Hetzer ()
returnDocument (a:ax) = writeLBS $ encode $ userFromDocument a
returnDocument [] = writeBS "user does not exist"

getUsers :: Handler Hetzer Hetzer ()
getUsers = do
    documents <- liftIO $ performAction $ (DB.find (DB.select [] "users") >>= DB.rest)
    writeLBS $ encode $ liftToJSON toJSON toJSON $ Data.List.map userFromDocument documents

hetzer = makeSnaplet "hetzer" "hetzer" Nothing $ do
    addRoutes handlers
    return $ Hetzer (DatabaseConfig "0.0.0.0" "my_database")

main :: IO ()
main = serveSnaplet defaultConfig hetzer

