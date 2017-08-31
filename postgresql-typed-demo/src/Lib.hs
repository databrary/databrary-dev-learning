{-# LANGUAGE TemplateHaskell, OverloadedStrings, QuasiQuotes, ScopedTypeVariables, DataKinds #-}
module Lib
    ( someFunc
    ) where

import Database.PostgreSQL.Typed
import Data.Int

useTPGDatabase
  (defaultPGDatabase
     { pgDBName = "mydb", pgDBUser = "kanishka", pgDBPass = "1" })

someFunc :: IO ()
someFunc = do
  putStrLn "hi"
  firstQuery

-- connect to db as postgres; create role w/pass
-- switch to user; ensure can connect w/tcp + pass; create db; create table

firstQuery :: IO ()
firstQuery = do
  c <- pgConnect (defaultPGDatabase { pgDBName = "mydb", pgDBUser = "kanishka", pgDBPass = "1" })
  let name = 1
  people :: [Maybe Int32] <- pgQuery c [pgSQL|SELECT c1 from t1|]
  print people
  pgDisconnect c
