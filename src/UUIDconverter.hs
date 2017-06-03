module UUIDconverter where

import Data.UUID
import Data.Maybe
import qualified Database.MongoDB as DB

mongoUUIDtoUUID :: DB.UUID -> Maybe UUID
mongoUUIDtoUUID (DB.UUID str) = fromASCIIBytes str
