{-# LANGUAGE OverloadedStrings #-}
module Main where

import DatabaseConfig
import Hetzer

import qualified UsersRepository as UR
import qualified BooksResource as BR

import qualified Database.MongoDB as DB
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

root = [
        ("/", serveFile "index.html"),
        ("/dist", serveDirectory "dist"),
        ("/css", serveDirectory "css")
    ]

hetzerInit db_conf pipe = makeSnaplet "hetzer" "hetzer" Nothing $ do
    addRoutes (UR.handlers ++ BR.handlers ++ root)
    return $ Hetzer db_conf pipe

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
    decoded <- toExceptT $ (eitherDecode :: LBS.ByteString -> Either String DatabaseConfig) $ BSC8.pack content
    pipe <- liftIO $ connectDatabase decoded
    liftIO $ serveSnaplet defaultConfig (hetzerInit decoded pipe)
    liftIO $ DB.close pipe

main :: IO ()
main = do
    error <- runExceptT runHetzer
    either (\e -> putStrLn e) (\x -> return ()) error

toExceptT :: Either String a -> ExceptT String IO a
toExceptT (Right x) = lift $ (return :: a -> IO a) x
toExceptT (Left x) = throwE x
