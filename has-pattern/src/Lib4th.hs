{-# LANGUAGE TemplateHaskell, OverloadedStrings #-}
module Lib4th
where

import Control.Monad (liftM2)
-- import Database.PostgreSQL.Typed.Enum (PGEnum, pgEnumValues, makePGEnum)
import qualified Language.Haskell.TH as TH
import qualified Data.ByteString.Char8 as BSC
import qualified Data.ByteString.UTF8 as U

-- a record type that has a string label/type name, corresponds to db table name?
class Kinded a where
  kindOf :: a -> String

-- class  PGEnumish a where  -- an instance for this is generated in makePGEnum as well
--  pgEnumVals :: [(a, String)]

-- enum class and code generation
class Kinded a => DBEnum a

toCamel :: String -> String
toCamel = id

makePGEnum :: String -> String -> (String -> String) -> TH.DecsQ
makePGEnum name typs valnf = do
  let valn = map (\v -> (TH.StringL (BSC.unpack v), TH.mkName $ valnf (U.toString v))) ["V1", "V2"]
  return [ TH.DataD [] (TH.mkName typs) [] (map (\(_,n) -> TH.NormalC n []) valn) [''Eq] ]

makeDBEnum :: String -> String -> TH.DecsQ
makeDBEnum name typs = -- do
  -- [] <- useTDB
  liftM2 (++)
    (makePGEnum name typs (\s -> typs ++ toCamel s))
    [d| instance Kinded $(return typt) where
          kindOf _ = $(TH.litE $ TH.stringL name)
        instance DBEnum $(return typt)
    |]
  where
  typt = TH.ConT (TH.mkName typs)
