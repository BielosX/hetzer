{-# LANGUAGE DeriveGeneric #-}
module User where

import Database.MongoDB
import Data.Text
import GHC.Generics
import Data.Aeson

data User = User {
                    name :: String,
                    email :: String
                } deriving (Show, Generic)

instance FromJSON User where

userToDocument :: User -> Document
userToDocument user = [pack "name" =: name user, pack "email" =: email user]
