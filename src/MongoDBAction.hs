module MongoDBAction(performAction) where

import DatabaseConfig
import Hetzer

import qualified Database.MongoDB as DB

import Snap.Snaplet
import Control.Monad.State
import Data.Text
import Control.Monad.Trans (liftIO)

getAccessMode :: DB.AccessMode
getAccessMode = DB.master

performAction :: DB.Action IO b -> Handler Hetzer Hetzer b
performAction action = do
    connection <- gets _database_connection
    conf <- gets _database_conf
    result <- liftIO $ DB.access connection getAccessMode (pack $ database_name conf) action
    return result
