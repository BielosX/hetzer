{-# LANGUAGE OverloadedStrings #-}
module Main where

import HetzerConfig
import DatabaseConfig
import Hetzer
import WebToken
import Auth

import qualified UsersRepository as UR
import qualified BooksResource as BR
import qualified LogIn as LI

import qualified RedisConfig as RC
import qualified Database.MongoDB as DB
import qualified Database.Redis as Redis
import qualified Data.List as List
import qualified System.IO as IO
import qualified Data.ByteString.Lazy.Char8 as BSC8
import qualified Data.ByteString.Lazy as LBS

import Control.Applicative
import Snap.Core
import Snap.Util.FileServe
import Snap.Http.Server
import Snap.Snaplet
import Data.Text.Encoding
import Control.Applicative
import Control.Monad
import Control.Monad.State
import System.Environment
import Data.Maybe
import Data.Either.Unwrap
import Data.Aeson
import Control.Monad.Trans.Except
import Control.Monad.Except
import Snap.Util.FileServe
import Crypto.JOSE.JWK
import Data.List

root = [
        ("/", serveFile "index.html"),
        ("/dist", serveDirectory "dist"),
        ("/css", serveDirectory "css")
    ]

restricted = fmap (\l -> fmap (\(a,b) -> (a, authorize b)) l) [UR.restrictedHandlers, BR.handlers]
endpoints = [LI.handlers, root, UR.handlers]

hetzerInit db_conf pipe redis_conn jwk = makeSnaplet "hetzer" "hetzer" Nothing $ do
    addRoutes $ Data.List.concat (restricted ++ endpoints)
    return $ Hetzer db_conf pipe redis_conn jwk

getConfFilePath :: [String] -> Either String FilePath
getConfFilePath [] = Right "./hetzer_conf.json"
getConfFilePath (a:ax) | a == "--config" = getPath $ List.take 1 ax
                       | otherwise = getConfFilePath ax

getPath :: [String] -> Either String FilePath
getPath [] = Left "Config file path is not specified."
getPath (a:ax) = Right a

runHetzer :: ExceptT String IO ()
runHetzer = do
    args <- liftIO $ getArgs
    path <- toExceptT $ getConfFilePath args
    content <- liftIO $ IO.readFile path
    decoded <- toExceptT $ (eitherDecode :: LBS.ByteString -> Either String HetzerConfig) $ BSC8.pack content
    pipe <- liftIO $ connectDatabase (mongo decoded)
    redisConn <- liftIO $ Redis.checkedConnect (redisConnectInfo $ RC.addr $ redis decoded)
    liftIO $ Redis.runRedis redisConn $ Redis.set "appName" "hetzer"
    jwk  <- liftIO $ genJWK (RSAGenParam 512)
    liftIO $ serveSnaplet defaultConfig (hetzerInit (mongo decoded) pipe redisConn jwk)
    liftIO $ DB.close pipe
    liftIO $ Redis.runRedis redisConn $ Redis.quit
    return ()

main :: IO ()
main = do
    error <- runExceptT runHetzer
    either (\e -> putStrLn e) (\x -> return ()) error

toExceptT :: Either String a -> ExceptT String IO a
toExceptT (Right x) = lift $ (return :: a -> IO a) x
toExceptT (Left x) = throwE x

redisConnectInfo :: String -> Redis.ConnectInfo
redisConnectInfo host = Redis.defaultConnectInfo { Redis.connectHost = host }

