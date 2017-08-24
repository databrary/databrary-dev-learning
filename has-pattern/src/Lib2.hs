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

instance Has a a where -- every object contains itself...but why need this?
  view = id

instance Has Int String where
  view s = length s

-- instance Has Day UTCTime where
--   view = utctDay

