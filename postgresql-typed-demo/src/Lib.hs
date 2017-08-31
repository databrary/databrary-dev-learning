{-# LANGUAGE TemplateHaskell, OverloadedStrings, QuasiQuotes, ScopedTypeVariables, DataKinds #-}
module Lib
    ( someFunc
    ) where

import Database.PostgreSQL.Typed
import Data.Int
import Database.PostgreSQL.Typed.Query

useTPGDatabase
  (defaultPGDatabase
     { pgDBName = "mydb", pgDBUser = "kanishka", pgDBPass = "1" })

someFunc :: IO ()
someFunc = do
  putStrLn "hi"
  firstQuery
  c <- pgConnect (defaultPGDatabase { pgDBName = "mydb", pgDBUser = "kanishka", pgDBPass = "1" })
  secondQuery c
  thirdQuery c
  qry4 c
  qry5 c
  qry6 c
  qry7 c
  pgDisconnect c

-- connect to db as postgres; create role w/pass
-- switch to user; ensure can connect w/tcp + pass; create db; create table

firstQuery :: IO ()
firstQuery = do
  c <- pgConnect (defaultPGDatabase { pgDBName = "mydb", pgDBUser = "kanishka", pgDBPass = "1" })
  people :: [Maybe Int32] <- pgQuery c [pgSQL|SELECT c1 from t1|]
  print people
  pgDisconnect c

secondQuery :: PGConnection -> IO ()
secondQuery c = do
  let val1 :: String = "abc"
  people :: [Maybe Int32] <- pgQuery c [pgSQL| SELECT c1 from t1 where 'ex' = ${val1} |]
  print people

thirdQuery :: PGConnection -> IO ()
thirdQuery c = do
  let val1 :: Int32 = 10
  people :: [Maybe Int32] <- pgQuery c [pgSQL| SELECT c1 from t1 where 11 = ${val1} |]
  print people

qry4 :: PGConnection -> IO ()
qry4 c = do
  let val1 :: Int32 = 1
  people :: [Maybe Int32] <- pgQuery c [pgSQL| SELECT c1 from t1 where c1 = ${val1} |]
  print people

qry5 :: PGConnection -> IO ()
qry5 c = do
  affected <- pgExecute c [pgSQL| INSERT INTO t1 (c1) values (3) |]
  print ("rows modified", affected)

qry6 :: PGConnection -> IO ()
qry6 c = do
  rows :: [Maybe Int32] <- pgQuery c ([pgSQL| SELECT c1 from t1 |] :: PGSimpleQuery (Maybe Int32))
  print rows

qry7 :: PGConnection -> IO ()
qry7 c = do
  let val1 :: Int32 = 1
  people :: [Maybe Int32] <-
    pgQuery
      c
      (([pgSQL| SELECT c1 from t1 where c1 = $1 |] :: Int32 -> PGSimpleQuery (Maybe Int32))
       val1)
  print people
