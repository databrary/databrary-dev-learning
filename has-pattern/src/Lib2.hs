{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances, ConstraintKinds, TemplateHaskell, TypeSynonymInstances, LiberalTypeSynonyms #-}
module Lib2
where

someFunc :: IO ()
someFunc =
  print "hi"

tryHas :: ()
tryHas =
   let _ = (view "abc" :: String)
       _ = (view "efg" :: Int)
   in ()

class Has a c where -- c is the containing object, a is the extractable part, view extracts it
  view :: c -> a

instance Has a a where
  view = id

instance Has Int String where
  view s = length s

-- instance Has Day UTCTime where
--   view = utctDay

{-
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
-}
