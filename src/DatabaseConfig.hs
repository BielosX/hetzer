{-# LANGUAGE DeriveGeneric #-}
module DatabaseConfig where

import qualified Database.MongoDB as DB

import Data.Aeson
import GHC.Generics

data DatabaseConfig = DatabaseConfig {
    database_addr :: String,
    database_name :: String
} deriving (Show, Generic)

instance FromJSON DatabaseConfig where
instance ToJSON DatabaseConfig where

connectDatabase :: DatabaseConfig -> IO DB.Pipe
connectDatabase config = DB.connect $ DB.host $ database_addr config
