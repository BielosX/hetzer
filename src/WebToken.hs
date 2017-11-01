{-# LANGUAGE DeriveGeneric #-}
module WebToken where

import Crypto.JOSE.JWS
import Crypto.JOSE.JWK
import Crypto.JOSE.Error

import qualified Data.ByteString.Lazy as B

import GHC.Generics
import Data.Aeson
import Data.UUID
import Control.Monad.Except
import Data.Either
import Data.Maybe
import Data.Bifunctor

data TokenPayload = TokenPayload {
    user_id :: UUID,
    salt ::  Int
} deriving(Show, Generic)

instance FromJSON TokenPayload where
instance ToJSON TokenPayload where

doJwsSign :: JWK -> TokenPayload -> IO (Either Error (GeneralJWS JWSHeader))
doJwsSign jwk payload = runExceptT $ do
    alg <- bestJWSAlg jwk
    signJWS p [(newJWSHeader (Protected, alg), jwk)]
    where p = encode payload

doJwsVerify :: JWK -> B.ByteString -> IO (Either String TokenPayload)
doJwsVerify jwk token = do
    jws <- return $ decode token
    result <- runExceptT $ verifyJWS' (jwk :: JWK) ((fromJust jws) :: GeneralJWS JWSHeader) :: IO (Either Error B.ByteString)
    return (first show result >>= eitherDecode)

