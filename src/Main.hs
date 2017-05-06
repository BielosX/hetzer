{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Applicative
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server
import           User
import Database.MongoDB
import Control.Monad.Trans (liftIO)
import Control.Monad.IO.Class
import Data.ByteString
import Data.Aeson

getDatabase :: Database
getDatabase = "my_database"

getAccessMode :: AccessMode
getAccessMode = master

getDatabaseAddr = "0.0.0.0"

performAction action = do
    pipe <- connect $ host $ getDatabaseAddr
    e <- access pipe getAccessMode getDatabase action
    close pipe

main :: IO ()
main = quickHttpServe site

site :: Snap ()
site =
    ifTop (writeBS "hello world") <|>
    route [
            ("users", method POST addNewUser)
          ] <|>
    dir "static" (serveDirectory ".")

addNewUser :: Snap ()
addNewUser = do
    body <- readRequestBody 2048
    user <- return (decode body)
    maybe (writeBS "unable to parse JSON")
        (liftIO . performAction . insert "users" . userToDocument) user



