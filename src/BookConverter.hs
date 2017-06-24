module BookConverter(bookToDocument, bookFromDocument) where

import Book
import UUIDconverter
import Date

import qualified Database.MongoDB as DB
import qualified Data.Text as TXT
import qualified Data.List as List

import Data.Aeson
import Data.UUID
import Data.Maybe
import Control.Applicative

bookToDocument :: Book -> DB.Document
bookToDocument book = getZipList ((DB.=:) <$> fields <*> values)
    where new_id = maybeUUIDtoMongoValue $ Book.id book
          fields = zipListFields [
                                    "_id",
                                    "title",
                                    "author",
                                    "isbn",
                                    "genere",
                                    "published",
                                    "quantity",
                                    "left"
                                ]
          values = ZipList [
                                DB.val $ new_id,
                                DB.val $ title book,
                                DB.val $ author book,
                                DB.val $ isbn book,
                                DB.val $ genere book,
                                DB.val $ show $ published book,
                                DB.val $ quantity book,
                                DB.val $ left book
                            ]

bookFromDocument :: DB.Document -> Book
bookFromDocument doc = Book id title author isbn genere published quantity left
    where id = mongoUUIDtoUUID $ getValue "_id" doc
          title = getValue "title" doc
          author = getValue "author" doc
          isbn = getValue "isbn" doc
          genere = getValue "genere" doc
          published = (read :: String -> Date) $ getValue "published" doc
          quantity = getValue "quantity" doc
          left = getValue "left" doc

getValue :: DB.Val a => String -> DB.Document -> a
getValue s = DB.typed . DB.valueAt (TXT.pack s)

zipListFields :: [String] -> ZipList TXT.Text
zipListFields = ZipList . List.map TXT.pack
