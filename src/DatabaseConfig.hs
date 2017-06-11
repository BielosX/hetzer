module DatabaseConfig where

import qualified Database.MongoDB as DB

data DatabaseConfig = DatabaseConfig {
    databse_addr :: String,
    database_name :: String
}

connectDatabase :: DatabaseConfig -> IO DB.Pipe
connectDatabase config = DB.connect $ DB.host $ databse_addr config
