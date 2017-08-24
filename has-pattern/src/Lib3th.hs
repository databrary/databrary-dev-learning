{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances, ConstraintKinds, TemplateHaskell, TypeSynonymInstances, LiberalTypeSynonyms #-}
module Lib3th
where

import Control.Monad (unless, liftM, liftM2)
import qualified Language.Haskell.TH as TH

class Has a c where -- c is the containing object, a is the extractable part, view extracts it
  view :: c -> a

instance Has a a where -- every object contains itself...but why need this?
  view = id

instance Has Int String where
  view s = length s

-- instance Has Day UTCTime where
--   view = utctDay

getFieldType :: TH.Name -> TH.Name -> TH.TypeQ
getFieldType tn fn = do
  TH.VarI _ (TH.ArrowT `TH.AppT` TH.ConT tn' `TH.AppT` ft) _ _ <- TH.reify fn
  unless (tn' == tn) $ fail $ show tn ++ "." ++ show fn ++ ": field from wrong type: " ++ show tn'
  return ft

makeHasFor :: TH.Name -> [(TH.Name, TH.Type, [TH.Type])] -> TH.DecsQ
makeHasFor tn fs = concat <$> mapM
  (\(fn, ft, ts) -> concatM
    [d| instance Has $(return ft) $(return tt) where
          view = $(TH.varE fn) |]
    (\st ->
      [d| instance Has $(return st) $(return tt) where
            view = view . $(TH.varE fn) |])
    ts)
  fs
  where
  tt = TH.ConT tn
  concatM i f l = liftM2 (++) i (liftM concat $ mapM f l)

makeHasRec :: TH.Name -> [TH.Name] -> TH.DecsQ
makeHasRec tn fs = do
  TH.ClassI _ il <- TH.reify ''Has
  makeHasFor tn =<< mapM (\fn -> do
    ft <- getFieldType tn fn
    return (fn, ft, [ st
      | TH.InstanceD _ (TH.ConT hs `TH.AppT` st `TH.AppT` ft') _ <- il
      , hs == ''Has
      , ft' == ft
      ]))
    fs



