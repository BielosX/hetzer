{-# LANGUAGE OverloadedStrings #-}
module BooksRepositoryMongoDB(BooksRepositoryMongoDB(..), get, save, findAll) where

import Book
import BooksRepository
import MongoDBAction
import BookConverter
import UUIDconverter

import qualified Database.MongoDB as DB

import System.Random
import Data.Text
import Data.List

data BooksRepositoryMongoDB = BooksRepositoryMongoDB {
    connection :: DB.Pipe,
    db_name :: String
 }

instance BooksRepository BooksRepositoryMongoDB where
    get r uuid = do
             book <- execute (connection r) (pack $ db_name r) (DB.find (selectBookById uuid) >>= DB.next)
             return (fmap bookFromDocument book)

    save r book = do
             uuid <- randomIO
             execute (connection r) (pack $ db_name r) $ insertBook book uuid
             return ()

    findAll r = do
            documents <- execute (connection r) (pack $ db_name r) $ findAllBooks
            return (Data.List.map bookFromDocument documents)

selectBookById uuid = DB.select ["_id" DB.=: (uuidToMongoUUID uuid)] "books"

insertBook book uuid = DB.insert "books" $ bookToDocument $ book {Book.id = Just uuid}

findAllBooks = DB.find (DB.select [] "books") >>= DB.rest

