{-# LANGUAGE OverloadedStrings #-}
module Main where

import DatabaseConfig
import Hetzer

import qualified UsersRepository as UR
import qualified Database.MongoDB as DB

import Control.Applicative
import Snap.Core
import Snap.Util.FileServe
import Snap.Http.Server
import Snap.Snaplet
import Data.ByteString
import Data.Text.Encoding
import Control.Applicative
import Control.Monad
import Control.Monad.State


hetzerInit db_conf pipe = makeSnaplet "hetzer" "hetzer" Nothing $ do
    addRoutes UR.handlers
    return $ Hetzer db_conf pipe

main :: IO ()
main = do
    db_conf <- return $ DatabaseConfig "0.0.0.0" "my_database"
    pipe <- connectDatabase db_conf
    serveSnaplet defaultConfig (hetzerInit db_conf pipe)
    DB.close pipe

