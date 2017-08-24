{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances, ConstraintKinds, TemplateHaskell, TypeSynonymInstances, LiberalTypeSynonyms #-}
module Lib3
where

import Lib3th

someFunc :: IO ()
someFunc =
  print "hi"

data Record2 = Record2
  { field1 :: Char  -- why does this cause an error when field1 is an Int??
  , field2 :: String
  }

makeHasRec ''Record2 ['field1, 'field2]

-- getFieldType ''Record2 'field1  -- decide how to turn "type" into [declaration]

makeHasFor ''Record2 []

-- makeHasFor ''Record2 [('field1, .., [...])]
