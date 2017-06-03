{-# LANGUAGE DeriveGeneric #-}
module User where

import qualified Database.MongoDB as DB
import qualified Data.Text as TXT
import GHC.Generics
import Data.Aeson
import Data.UUID
import Data.Maybe
import Data.ByteString
import qualified Data.Typeable as Typeable
import UUIDconverter
import qualified Data.List as List
import Control.Applicative

data User = User {
                    id :: Maybe UUID,
                    name :: String,
                    email :: String
                } deriving (Show, Generic)

instance FromJSON User where
instance ToJSON User where

userToDocument :: User -> DB.Document
userToDocument user = getZipList ((DB.=:) <$> fields <*> values)
    where new_id = fromMaybe DB.Null (fmap (DB.val . DB.UUID . toASCIIBytes) $ User.id user)
          fields = ZipList $ List.map TXT.pack ["_id", "name", "email"]
          values = ZipList [DB.val $ new_id, DB.val $ name user, DB.val $ email user]

userFromDocument :: DB.Document -> User
userFromDocument doc = User id name email
    where id = mongoUUIDtoUUID $ DB.typed $ DB.valueAt (TXT.pack "_id") doc
          name = DB.typed $ DB.valueAt (TXT.pack "name") doc
          email = DB.typed $ DB.valueAt (TXT.pack "email") doc

