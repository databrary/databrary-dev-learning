{-# LANGUAGE TemplateHaskell, OverloadedStrings, QuasiQuotes, ScopedTypeVariables, DataKinds,
             FlexibleContexts #-}
module Lib4
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
-- create table tag_use ( use_role varchar(32) not null, tag_id integer not null);
-- insert into tag_use values ('for fun', 1)
-- insert into tag_use values ('for work', 1)
-- insert into tag values (2, 'efg')
-- insert into tag_use values ('unsure', 2)
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
  -- using selectDistinctQuery with a selector made with joinOn
  rows2 :: [TagUse] <- pgQuery c $(selectDistinctQuery Nothing selectTagUse "")
  -- using selectDistinctQuery with a selector made with manual joinOn
  rows3 :: [TagUse] <- pgQuery c $(selectDistinctQuery Nothing selectTagUse7 "")
  -- using makePGQuery, same as join above
  rows4 :: [TagUse] <-
    (fmap (\(rl, tid, nm) -> ($) (TagUse rl) (Tag tid nm)))
      <$>
       pgQuery c
         $(makePGQuery
             (fst (parseQueryFlags ""))
             (    " SELECT tag_use.use_role,tag.id,tag.name"
               ++ " FROM tag_use JOIN tag ON tag_use.tag_id = tag.id "))
  print tags1
  print tags2
  print rows
  print rows2
  print rows3
  print rows4
  pgDisconnect c

{-
src/Lib4.hs:68:36-79: Splicing expression
    selectDistinctQuery Nothing selectTagUse7 ""
  ======>
    fmap
      (\ (vrole_aoTj, vid_aoTk, vname_aoTl)
         -> ($) (TagUse vrole_aoTj) (Tag vid_aoTk vname_aoTl))
      (\ -> Database.PostgreSQL.Typed.Query.QueryParser
              (\ _tenv_aoTm
                 -> Database.PostgreSQL.Typed.Query.SimpleQuery
                      (bytestring-0.10.6.0:Data.ByteString.concat
                         [Data.String.fromString
                            "SELECT tag_use.use_role,tag.id,tag.name FROM tag_use JOIN tag ON tag_use.tag_id = tag.id "]))
              (\ _tenv_aoTm [_cuse_role_aoTn, _cid_aoTo, _cname_aoTp]
                 -> (pgDecodeColumnNotNull
                       _tenv_aoTm
                       (PGTypeProxy :: PGTypeName "character varying")
                       _cuse_role_aoTn,
                     pgDecodeColumnNotNull
                       _tenv_aoTm (PGTypeProxy :: PGTypeName "integer") _cid_aoTo,
                     pgDecodeColumnNotNull
                       _tenv_aoTm
                       (PGTypeProxy :: PGTypeName "character varying")
                       _cname_aoTp)))
-}
