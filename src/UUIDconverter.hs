module UUIDconverter where

import Data.UUID
import Data.Maybe
import qualified Database.MongoDB as DB

mongoUUIDtoUUID :: DB.UUID -> Maybe UUID
mongoUUIDtoUUID (DB.UUID str) = fromASCIIBytes str

uuidToMongoUUID :: UUID -> DB.UUID
uuidToMongoUUID = DB.UUID . toASCIIBytes

maybeUUIDtoMongoValue :: Maybe UUID -> DB.Value
maybeUUIDtoMongoValue uuid = fromMaybe DB.Null (fmap (DB.val . uuidToMongoUUID) uuid)
