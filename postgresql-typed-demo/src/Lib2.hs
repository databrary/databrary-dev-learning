{-# LANGUAGE TemplateHaskell, OverloadedStrings, QuasiQuotes, ScopedTypeVariables, DataKinds,
             FlexibleContexts #-}
module Lib2
    ( someFunc
    ) where

import Control.Arrow (second)
import Database.PostgreSQL.Typed
import Data.Int
import Control.Monad.State (StateT(..))
import Control.Monad.Trans.Class (lift)
import Data.Char (isLetter, toLower)
import Data.List (intercalate, unfoldr)
import qualified Language.Haskell.TH as TH
import Database.PostgreSQL.Typed.Query (QueryFlags, parseQueryFlags, makePGQuery)
import Control.Monad.Trans.Class (lift)

useTPGDatabase
  (defaultPGDatabase
     { pgDBName = "mydb", pgDBUser = "kanishka", pgDBPass = "1" })

someFunc :: IO ()
someFunc = do
  putStrLn "hi"
  -- tags :: [(String, Int)]
  --    <- pgQuery c $(selectDistinctQuery Nothing selectTag "$WHERE tag.name = ${n}::varchar")

-- 1. Tag defined as record
-- 2. simplify w/Tag defined as tuple only

-- 'Tag needs a data definition; possibly pgquery instance that comes with makehasrec
-- selectTag :: Selector -- ^ @'Tag'@
-- selectTag = selectColumns 'Tag "tag" ["id", "name"]

-- dbQuery1 $(selectDistinctQuery Nothing selectTag "$WHERE tag.name = ${n}::varchar")

-------- Making a SelectOutput instance ---------
data Tag = Tag { tagId :: Int32, tagName :: String }

tagOutput :: SelectOutput
tagOutput =
  OutputJoin {
      outputNullable = False
    , outputJoiner = 'Tag
    , outputJoin =
        [ SelectColumn { _selectTable = "tag", _selectColumn = "id" }
        , SelectColumn { _selectTable = "tag", _selectColumn = "name" } ]
  }

------------------
data SelectOutput
  = SelectColumn { _selectTable, _selectColumn :: String }
  | SelectExpr String
  | OutputJoin { outputNullable :: !Bool, outputJoiner :: TH.Name, outputJoin :: [SelectOutput] } 
  | OutputMap { outputNullable :: !Bool, outputMapper :: TH.Exp -> TH.Exp, outputMap :: SelectOutput } -- ?

--------- Making a Selector instance ----------
tagSelector :: Selector
tagSelector =
  Selector {
    selectOutput = tagOutput
  , selectSource = "tag"
  , selectJoined = ",tag"
  }
   
-------------------
selectColumns :: TH.Name -> String -> [String] -> Selector
selectColumns f t c =
  selector t $ OutputJoin False f $ map (SelectColumn t) c

selector :: String -> SelectOutput -> Selector
selector t o = Selector o t (',':t)

data Selector = Selector
  { selectOutput :: SelectOutput
  , selectSource :: String
  , selectJoined :: String -- get example of where is this used?
  }

--------- Build up columns ------------
tagCols :: [String]
tagCols =
  concatMap
    (\(SelectColumn t c) -> [t ++ '.' : c])
    [SelectColumn "tag" "id", SelectColumn "tag" "name"]

tagCols2 :: [String]
tagCols2 = ["tag.id", "tag.name"]

------------------
outputColumns :: SelectOutput -> [String]
outputColumns (SelectColumn t c) = [t ++ '.' : c]
outputColumns (SelectExpr s) = [s]
outputColumns (OutputJoin _ _ o) = concatMap outputColumns o
outputColumns (OutputMap _ _ o) = outputColumns o

------------- Build up list of TH column names -----------

--   nl <- mapM (TH.newName . ('v':) . colVar) cols
--  colVar s = case takeWhileEnd isLetter s of
--    [] -> "c"
--    (h:l) -> toLower h : l

takeWhileEnd :: (a -> Bool) -> [a] -> [a]
takeWhileEnd p = fst . foldr go ([], False) where
  go x (rest, done)
    | not done && p x = (x:rest, False)
    | otherwise = (rest, True)


------------- Run output parser --------------------------



---------------
outputParser :: SelectOutput -> StateT [TH.Name] TH.Q TH.Exp
outputParser (OutputJoin mb f ol) = do
  fi <- lift $ TH.reify f
  (fe, ft) <- case fi of
    TH.ClassOpI _ t _ _ -> return (TH.VarE f, t)
    TH.DataConI _ t _ _ -> return (TH.ConE f, t)
    TH.VarI _ t _ _ -> return (TH.VarE f, t)
    _ -> die "wrong kind"
  if mb
    then do
      let am = unfoldr argMaybe ft
      (bl, ae) <- bindArgs am ol
      -- when (null bl) $ die "function with at least one non-Maybe argument required"
      return $ TH.DoE $ bl ++ [TH.NoBindS $ TH.AppE (TH.ConE 'Just) $ foldl TH.AppE fe ae]
    else foldl TH.AppE fe <$> mapM outputParser ol
  where
  bindArgs (False:m) (o:l) = do
    n <- lift $ TH.newName "cm"
    a <- outputParser (outputMaybe o)
    (bl, al) <- bindArgs m l
    return $ (TH.BindS (TH.VarP n) a : bl, TH.VarE n : al)
  bindArgs (True:m) (o:l) = do
    a <- outputParser o
    second (a:) <$> bindArgs m l
  bindArgs _ o = (,) [] <$> mapM outputParser o
  argMaybe (TH.ArrowT `TH.AppT` a `TH.AppT` r) = Just (isMaybeT a, r)
  argMaybe _ = Nothing
  isMaybeT (TH.AppT (TH.ConT m) _) = m == ''Maybe
  isMaybeT _ = False
  die s = fail $ "outputParser " ++ show f ++ ": " ++ s
outputParser (OutputMap False f o) =
  f <$> outputParser o
outputParser (OutputMap True f o) = do
  x <- lift $ TH.newName "x"
  ((TH.VarE 'fmap `TH.AppE` (TH.LamE [TH.VarP x] $ f $ TH.VarE x)) `TH.AppE`)
    <$> outputParser (outputMaybe o)
outputParser _ = StateT st where
  st (i:l) = return (TH.VarE i, l)
  st [] = fail "outputParser: insufficient values"

outputMaybe :: SelectOutput -> SelectOutput
outputMaybe (OutputJoin False f l) = OutputJoin True f l
outputMaybe (OutputMap False f l) = OutputMap True f l
outputMaybe s = s


------------ Make PG Query, Tranform result --------------

-- use mkpgquery

-- make TH function that applies a function to result of mkpgquery, eval the query

-- use makeQuery in its entirety




{-
makeQuery :: QueryFlags -> (String -> String) -> SelectOutput -> TH.ExpQ
makeQuery flags sql output = do
  -- _ <- useTDB
  nl <- mapM (TH.newName . ('v':) . colVar) cols
  (parse, []) <- runStateT (outputParser output) nl
  TH.AppE (TH.VarE 'fmap `TH.AppE` TH.LamE [TH.TupP $ map TH.VarP nl] parse)
    <$> makePGQuery flags (sql $ intercalate "," cols)
  where
  colVar s = case takeWhileEnd isLetter s of
    [] -> "c"
    (h:l) -> toLower h : l
  cols = outputColumns output


selectDistinctQuery :: Maybe [String] -> Selector -> String -> TH.ExpQ
selectDistinctQuery dist (Selector{ selectOutput = o, selectSource = s }) sqlf =
  makeQuery flags (\c -> select dist ++ c ++ " FROM " ++ s ++ ' ':sql) o
  where
  (flags, sql) = parseQueryFlags sqlf
  select Nothing = "SELECT " -- ALL
  select (Just []) = "SELECT DISTINCT "
  select (Just l) = "SELECT DISTINCT ON (" ++ intercalate "," l ++ ") "
-}
