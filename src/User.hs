{-# LANGUAGE DeriveGeneric #-}
module User where

import qualified Data.Typeable as Typeable

import GHC.Generics
import Data.Aeson
import Data.Maybe
import Data.UUID

data User = User {
                    id :: Maybe UUID,
                    name :: String,
                    email :: String,
                    password :: Maybe String
                } deriving (Show, Generic)

instance FromJSON User where
instance ToJSON User where

