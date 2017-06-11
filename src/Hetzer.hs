module Hetzer where

import DatabaseConfig

import qualified Database.MongoDB as DB

data Hetzer = Hetzer {
    _database_conf :: DatabaseConfig,
    _database_connection :: DB.Pipe
}
