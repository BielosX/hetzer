{-# LANGUAGE DeriveGeneric #-}
module User where

import Database.MongoDB
import qualified Data.Text as TXT
import GHC.Generics
import Data.Aeson
import Data.UUID
import Data.Maybe
import qualified Data.ByteString.Char8 as BS

data User = User {
                    id :: Maybe String,
                    name :: String,
                    email :: String
                } deriving (Show, Generic)

instance FromJSON User where
instance ToJSON User where

userToDocument :: User -> Document
userToDocument user = [TXT.pack "_id" =: new_id, TXT.pack "name" =: name user, TXT.pack "email" =: email user]
    where new_id = fromMaybe Database.MongoDB.Null (fmap (val . Database.MongoDB.UUID . BS.pack) $ User.id user)

userFromDocument :: Document -> User
userFromDocument doc = User id name email
    where id = Just $ (show :: Database.MongoDB.UUID -> String) $ typed $ valueAt (TXT.pack "_id") doc
          name = typed $ valueAt (TXT.pack "name") doc
          email = typed $ valueAt (TXT.pack "email") doc
