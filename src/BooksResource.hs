{-# LANGUAGE OverloadedStrings #-}
module BooksResource where

import Book
import BooksRepositoryMongoDB
import BooksRepository
import Hetzer
import DatabaseConfig

import qualified Database.MongoDB as DB
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Lazy.Char8 as CLBS

import Snap.Core
import Snap.Util.FileServe
import Snap.Http.Server
import Snap.Snaplet
import Control.Monad.IO.Class
import Data.ByteString
import Data.Aeson
import Control.Monad.State
import Data.Either

handlers :: [(ByteString, Handler Hetzer Hetzer ())]
handlers = [
                ("books", method GET getBooks),
                ("books", method POST addBook)
            ]

getBooks :: Handler Hetzer Hetzer ()
getBooks = do
    connection <- gets _database_connection
    conf <- gets _database_conf
    books <- liftIO $ findAll $ BooksRepositoryMongoDB connection (database_name conf)
    writeLBS $ encode $ liftToJSON toJSON toJSON $ books

addBook :: Handler Hetzer Hetzer ()
addBook = do
    connection <- gets _database_connection
    conf <- gets _database_conf
    body <- readRequestBody 2048
    book <- return $ (eitherDecode :: LBS.ByteString -> Either String Book) body
    repository <- return $ BooksRepositoryMongoDB connection (database_name conf)
    either (\err -> writeLBS $ LBS.concat ["unable to parse JSON.", CLBS.pack err]) (insertBook repository) book

insertBook :: (BooksRepository r) => r -> Book -> Handler Hetzer Hetzer ()
insertBook repository book = liftIO $ save repository book

