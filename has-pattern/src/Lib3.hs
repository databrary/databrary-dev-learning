{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances, ConstraintKinds, TemplateHaskell, TypeSynonymInstances, LiberalTypeSynonyms #-}
module Lib3
where

import Lib3th
import qualified Language.Haskell.TH as TH
import Language.Haskell.TH.Lift (deriveLift)

someFunc :: IO ()
someFunc =
  print "hi"

data Record2 = Record2
  { field1 :: Char  -- why does this cause an error when field1 is an Int??
  , field2 :: String
  , field3 :: SubRecord
  }

data SubRecord = SubRecord
  { subfield1 :: ValType
  }



data ValType = ValType

makeHasRec ''Record2 ['field1, 'field2]
makeHasRec ''SubRecord ['subfield1]

-- getFieldType ''Record2 'field1  -- decide how to turn "type" into [declaration]

makeHasFor ''Record2 []

 -- this needs Has SubRecord ValType... a little unclear on what is going on here
makeHasFor ''Record2 [('field3, TH.ConT ''SubRecord, [TH.ConT ''ValType])]


data Record3 = Record3
  { rc3Field1 :: Int }

deriveLift ''Record3 -- make this usable as parameter to a Template Haskell function which generates Haskell
