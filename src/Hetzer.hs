module Hetzer where

import DatabaseConfig

import qualified Database.MongoDB as DB
import qualified Database.Redis as Redis

import Crypto.JOSE.JWK

data Hetzer = Hetzer {
    _database_conf :: DatabaseConfig,
    _database_connection :: DB.Pipe,
    _redis_connection :: Redis.Connection,
    _jwk :: JWK
}
