module BooksRepository where

import Book

import Data.Maybe
import Data.UUID

class BooksRepository r where
    get :: r -> UUID -> IO (Maybe Book)
    save :: r -> Book -> IO ()
    findAll :: r -> IO [Book]
