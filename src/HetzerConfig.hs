{-# LANGUAGE DeriveGeneric #-}
module HetzerConfig where

import qualified Database.MongoDB as DB

import Data.Aeson
import GHC.Generics

import DatabaseConfig
import RedisConfig

data HetzerConfig = HetzerConfig {
    mongo :: DatabaseConfig,
    redis :: RedisConfig
} deriving (Show, Generic)

instance FromJSON HetzerConfig where
instance ToJSON HetzerConfig where
