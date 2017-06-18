module UserConverter where

import User
import UUIDconverter

import qualified Database.MongoDB as DB
import qualified Data.Text as TXT
import qualified Data.List as List

import Data.Aeson
import Data.UUID
import Data.Maybe
import Control.Applicative

userToDocument :: User -> DB.Document
userToDocument user = getZipList ((DB.=:) <$> fields <*> values)
    where new_id = maybeUUIDtoMongoValue $ User.id user
          fields = ZipList $ List.map TXT.pack ["_id", "name", "email"]
          values = ZipList [DB.val $ new_id, DB.val $ name user, DB.val $ email user]

userFromDocument :: DB.Document -> User
userFromDocument doc = User id name email
    where id = mongoUUIDtoUUID $ DB.typed $ DB.valueAt (TXT.pack "_id") doc
          name = DB.typed $ DB.valueAt (TXT.pack "name") doc
          email = DB.typed $ DB.valueAt (TXT.pack "email") doc
