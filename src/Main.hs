{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Applicative
import Snap.Core
import Snap.Util.FileServe
import Snap.Http.Server
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

main :: IO ()
main = quickHttpServe site

handlers = [
            ("users", method POST addNewUser),
            ("users", method GET getUsers),
            ("users/:userId", method GET getUser)
          ]

postFilters = [fields]

fields :: () -> Snap ()
fields () = do
    flds <- getQueryParam "fields"
    maybe (return ()) writeBS flds

applyFilters :: MonadSnap m => [a -> m a] -> [(ByteString, m a)] -> [(ByteString, m a)]
applyFilters post handlers = Data.List.map (\(bs, monad) -> (bs, monad >>= postFilters)) handlers
    where postFilters = Data.List.foldl (>=>) (\x -> return x) post

site :: Snap ()
site =
    ifTop (writeBS "hello world") <|>
    route (applyFilters postFilters handlers)  <|> dir "static" (serveDirectory ".")

addNewUser :: Snap ()
addNewUser = do
    body <- readRequestBody 2048
    user <- return (decode body)
    maybe (writeBS "unable to parse JSON") insertUser user

insertUser user = do
    uuid <- liftIO $ randomIO
    liftIO $ performAction $ DB.insert "users" $ userToDocument $ user {User.id = Just $ Data.UUID.toString uuid}
    return ()

getUser :: Snap ()
getUser = do
    param <- getParam "userId"
    loadUser param

loadUser :: Maybe ByteString -> Snap ()
loadUser (Just param) = do
    document <- liftIO $ performAction $ (DB.find (DB.select ["_id" DB.=: DB.UUID param] "users") >>= DB.rest)
    returnDocument document
loadUser Nothing = writeBS "userId is not specified"

returnDocument :: [DB.Document] -> Snap ()
returnDocument (a:ax) = writeLBS $ encode $ userFromDocument a
returnDocument [] = writeBS "user does not exist"

getUsers :: Snap ()
getUsers = do
    documents <- liftIO $ performAction $ (DB.find (DB.select [] "users") >>= DB.rest)
    writeLBS $ encode $ liftToJSON toJSON toJSON $ Data.List.map userFromDocument documents

