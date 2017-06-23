{-# LANGUAGE DeriveGeneric #-}
module Book where

import Date

import GHC.Generics
import Data.Aeson
import Data.Maybe
import Data.UUID

data Book = Book {
                    id :: Maybe UUID,
                    title :: String,
                    author :: String,
                    isbn :: String,
                    genere :: String,
                    published :: Date,
                    quantity :: Int,
                    left :: Int
                } deriving (Show, Generic)

instance FromJSON Book where
instance ToJSON Book where

