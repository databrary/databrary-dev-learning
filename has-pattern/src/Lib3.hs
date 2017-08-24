{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances, ConstraintKinds, TemplateHaskell, TypeSynonymInstances, LiberalTypeSynonyms #-}
module Lib3
where

import Lib3th

someFunc :: IO ()
someFunc =
  print "hi"

data Record = Record
  { field1 :: Int
  }

makeHasRec ''Record ['field1]

