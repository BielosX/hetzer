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

hetzerInit db_conf pipe = makeSnaplet "hetzer" "hetzer" Nothing $ do
    addRoutes (UR.handlers ++ BR.handlers)
    return $ Hetzer db_conf pipe

getConfFilePath :: [String] -> Maybe FilePath
getConfFilePath [] = Just "./hetzer_conf.json"
getConfFilePath (a:ax) | a == "--config" = getPath $ List.take 1 ax
                       | otherwise = getConfFilePath ax

getPath :: [String] -> Maybe FilePath
getPath [] = Nothing
getPath (a:ax) = Just a

main :: IO ()
main = do
    args <- getArgs
    path <- return $ getConfFilePath args
    if (isJust path) then do
        content <- IO.readFile (fromJust path)
        decoded <- return $ (eitherDecode :: LBS.ByteString -> Either String DatabaseConfig) $ BSC8.pack content
        if (isRight decoded) then do
            db_conf <- return $ fromRight decoded
            pipe <- connectDatabase db_conf
            serveSnaplet defaultConfig (hetzerInit db_conf pipe)
            DB.close pipe
        else
            IO.putStrLn $ fromLeft decoded
    else
        IO.putStrLn "Config file path is not specified."

