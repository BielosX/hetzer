module UserSpec (spec) where

import Test.Hspec
import Database.MongoDB
import Data.Text
import User

spec :: Spec
spec = do
    describe "userToField" $ do
        it "converts user to mongodb field" $ do
            let user = User "John" "john@acme.com"
            let expected = [ pack "name" =: "John", pack "email" =: "john@acme.com"]
            userToDocument user `shouldBe` expected
