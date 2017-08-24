{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances, ConstraintKinds, TemplateHaskell, TypeSynonymInstances, LiberalTypeSynonyms #-}
module Lib2
where



someFunc :: IO ()
someFunc =
  putStrLn "hi"

class Has a c where
  view :: c -> a

instance Has a a where
  view = id

-- instance Has Day Timestamp where
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
