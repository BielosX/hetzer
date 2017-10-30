{-# LANGUAGE DeriveGeneric #-}
module RedisConfig where

import qualified Database.MongoDB as DB

import Data.Aeson
import GHC.Generics

data RedisConfig = RedisConfig {
    addr :: String
} deriving (Show, Generic)

instance FromJSON RedisConfig where
instance ToJSON RedisConfig where
