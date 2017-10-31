module UserPasswd where

import User

import qualified Data.ByteString.Char8 as C

import Crypto.BCrypt
import Data.Maybe

encryptUserPasswd user = hashPasswordUsingPolicy policy  (C.pack $ fromMaybe "" $ password user)
    where policy = fastBcryptHashingPolicy

encryptPasswd passwd = hashPasswordUsingPolicy policy  (C.pack passwd)
    where policy = fastBcryptHashingPolicy

