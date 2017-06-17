{-# LANGUAGE DeriveGeneric #-}
module Date where

import Text.Printf
import Text.Show
import Text.Regex.TDFA
import Text.ParserCombinators.ReadP
import Text.Read

data Date = Date {
        year :: Int,
        month :: Int,
        day :: Int
    } deriving (Eq, Ord)

instance Show Date where
    showsPrec _ d = showString $ printf "%04d-%02d-%02d" (year d) (month d) (day d)

    show d = showsPrec 0 d ""

instance Read Date where
    readsPrec _ date = [(Date (readString y) (readString m) (readString d), rest)]
        where (_,_, rest, [y, m, d]) = matchDate date

    readPrec = lift $ readS_to_P $ (readsP :: ReadS Date)
        where readsP = readsPrec 0

matchDate :: String -> (String, String, String, [String])
matchDate date = date =~ "([0-9]{4})-([0-9]{2})-([0-9]{2})" :: (String, String, String, [String])

readString :: String -> Int
readString = (read :: String -> Int)
