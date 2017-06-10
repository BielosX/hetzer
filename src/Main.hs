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
import Control.Monad.State
import qualified Data.ByteString.Lazy as BS

data DatabaseConfig = DatabaseConfig {
    databse_addr :: String,
    database_name :: String
}

data Hetzer = Hetzer {
    _database_conf :: DatabaseConfig,
    _database_connection :: DB.Pipe
}

getDatabase :: DB.Database
getDatabase = "my_database"

getAccessMode :: DB.AccessMode
getAccessMode = DB.master

performAction conn action = do
    result <- DB.access conn getAccessMode getDatabase action
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
    user <- return $ (decode :: BS.ByteString -> Maybe User) body
    maybe (writeBS "unable to parse JSON") insertUser user

insertUser :: User -> Handler Hetzer Hetzer ()
insertUser user = do
    uuid <- liftIO $ randomIO
    connection <- gets _database_connection
    liftIO $ performAction connection $ DB.insert "users" $ userToDocument $ user {User.id = Just uuid}
    return ()

getUser :: Handler Hetzer Hetzer ()
getUser = do
    param <- getParam "userId"
    loadUser param

loadUser :: Maybe ByteString -> Handler Hetzer Hetzer ()
loadUser (Just param) = do
    connection <- gets _database_connection
    document <- liftIO $ performAction connection $ (DB.find (DB.select ["_id" DB.=: DB.UUID param] "users") >>= DB.rest)
    returnDocument document
loadUser Nothing = writeBS "userId is not specified"

returnDocument :: [DB.Document] -> Handler Hetzer Hetzer ()
returnDocument (a:ax) = writeLBS $ encode $ userFromDocument a
returnDocument [] = writeBS "user does not exist"

getUsers :: Handler Hetzer Hetzer ()
getUsers = do
    connection <- gets _database_connection
    documents <- liftIO $ performAction connection $ (DB.find (DB.select [] "users") >>= DB.rest)
    writeLBS $ encode $ liftToJSON toJSON toJSON $ Data.List.map userFromDocument documents

hetzerInit db_conf pipe = makeSnaplet "hetzer" "hetzer" Nothing $ do
    addRoutes handlers
    return $ Hetzer db_conf pipe

connectDatabase :: DatabaseConfig -> IO DB.Pipe
connectDatabase config = DB.connect $ DB.host $ databse_addr config

main :: IO ()
main = do
    db_conf <- return $ DatabaseConfig "0.0.0.0" "my_database"
    pipe <- connectDatabase db_conf
    serveSnaplet defaultConfig (hetzerInit db_conf pipe)
    DB.close pipe

