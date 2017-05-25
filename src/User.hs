{-# LANGUAGE DeriveGeneric #-}
module User where

import qualified Database.MongoDB as DB
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

userToDocument :: User -> DB.Document
userToDocument user = [TXT.pack "_id" DB.=: new_id, TXT.pack "name" DB.=: name user, TXT.pack "email" DB.=: email user]
    where new_id = fromMaybe DB.Null (fmap (DB.val . DB.UUID . BS.pack) $ User.id user)

userFromDocument :: DB.Document -> User
userFromDocument doc = User id name email
    where id = Just $ (show :: DB.UUID -> String) $ DB.typed $ DB.valueAt (TXT.pack "_id") doc
          name = DB.typed $ DB.valueAt (TXT.pack "name") doc
          email = DB.typed $ DB.valueAt (TXT.pack "email") doc
