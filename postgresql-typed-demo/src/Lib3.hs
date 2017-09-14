{-# LANGUAGE TemplateHaskell, OverloadedStrings, QuasiQuotes, ScopedTypeVariables, DataKinds,
             FlexibleContexts #-}
module Lib3
    ( someFunc
    ) where

import Lib2th
import Control.Arrow (second)
import Database.PostgreSQL.Typed
import Data.Int
import Control.Monad.State (StateT(..))
import Control.Monad.Trans.Class (lift)
import Data.Char (isLetter, toLower)
import Data.List (intercalate, unfoldr)
import qualified Language.Haskell.TH as TH
-- import Database.PostgreSQL.Typed.Query (QueryFlags, parseQueryFlags, makePGQuery)
import Database.PostgreSQL.Typed.Types
import Database.PostgreSQL.Typed.Query
import Control.Monad.Trans.Class (lift)

useTPGDatabase
  (defaultPGDatabase
     { pgDBName = "mydb", pgDBUser = "kanishka", pgDBPass = "1" })

{-
-- create table tag ( id integer not null, name varchar(32) not null);
-- insert into tag values (1, 'abc')
-- alter table tag add upid integer not null default 1
-- alter table tag add upname varchar(32) not null default 'dflt'
-}

someFunc :: IO ()
someFunc = do
  putStrLn "hi"
  let n = "abc" :: String
  c <- pgConnect (defaultPGDatabase { pgDBName = "mydb", pgDBUser = "kanishka", pgDBPass = "1" })
  -- using selectDistinctQuery
  tags1 :: [Tag]
     <- pgQuery c $(selectDistinctQuery Nothing selectTag "$WHERE tag.name = ${n}::varchar")
  -- using makeQuery
  tags2 <-
     pgQuery c
      $(makeQuery
                 (fst (parseQueryFlags "$WHERE tag.name = ${n}::varchar"))
                 (\_ ->
                        " SELECT tag.id,tag.name"
                     ++ " FROM tag "
                     ++ (snd (parseQueryFlags "$WHERE tag.name = ${n}::varchar")))
                 (OutputJoin
                    False
                    'Tag
                    [ SelectColumn "tag" "id"
                    , SelectColumn "tag" "name" ]))
  -- using makePGQuery
  rows :: [(Int32, String)] <-
    pgQuery c
      $(makePGQuery
          (fst (parseQueryFlags "$WHERE tag.name = ${n}::varchar"))
          "select tag.id, tag.name from tag where tag.name = ${n}::varchar")
  -- using selectDistinctQuery with a selector made with manual addSelects
  rows2 :: [TagUpload] <-
    pgQuery c
      $(selectDistinctQuery Nothing upSelector "")
  -- using selectDistinctQuery with a selector made with actual addSelects
  rows3 :: [TagUpload] <-
    pgQuery c
      $(selectDistinctQuery Nothing addSelectsUpload "")
  print tags1
  print tags2
  print rows
  print rows2
  print rows3
  pgDisconnect c

{-
src/Lib3.hs:82:9-49: Splicing expression
    selectDistinctQuery Nothing upSelector ""
  ======>
    fmap
      (\ (vid_aafQ, vname_aafR, vupid_aafS, vupname_aafT)
         -> makeUp (Tag vid_aafQ vname_aafR) vupid_aafS vupname_aafT)
      (\ -> Database.PostgreSQL.Typed.Query.QueryParser
              (\ _tenv_aag7
                 -> Database.PostgreSQL.Typed.Query.SimpleQuery
                      (bytestring-0.10.6.0:Data.ByteString.concat
                         [Data.String.fromString
                            "SELECT tag.id,tag.name,tag.upid,tag.upname FROM tag "]))
              (\ _tenv_aag7 [_cid_aag8, _cname_aag9, _cupid_aaga, _cupname_aagb]
                 -> (pgDecodeColumnNotNull
                       _tenv_aag7 (PGTypeProxy :: PGTypeName "integer") _cid_aag8,
                     pgDecodeColumnNotNull
                       _tenv_aag7
                       (PGTypeProxy :: PGTypeName "character varying")
                       _cname_aag9,
                     pgDecodeColumnNotNull
                       _tenv_aag7 (PGTypeProxy :: PGTypeName "integer") _cupid_aaga,
                     pgDecodeColumnNotNull
                       _tenv_aag7
                       (PGTypeProxy :: PGTypeName "character varying")
                       _cupname_aagb)))

-}
