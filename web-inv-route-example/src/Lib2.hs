{-# LANGUAGE OverloadedStrings, TypeOperators #-}
module Lib2
where

import qualified Data.Invertible.Bijection as BI
import qualified Control.Invertible.Functor as FN
import qualified Control.Invertible.Monoidal as MN

import Web.Route.Invertible
import qualified Data.Invertible as I

------------------------------------ invertible library abstractions
-- bijection
data NumBool = Zero | One deriving Eq

biject1 :: Bool BI.<-> NumBool  -- uses Bijection (->) a b specialization
biject1 =
  (:<->:) {
    biTo = (\b -> if b == True then One else Zero)
  , biFrom = (\nb -> if nb == Zero then False else True)
  }

useBiTo :: NumBool
useBiTo = (biTo biject1) True

-- data.functor.invariant from invariant package ...

-- invariant functor (invertible.functor) imitation built over invertible.bijection
instance FN.Functor Maybe where
  -- fmap :: (Bool BI.<-> NumBool) -> Maybe Bool -> Maybe NumBool
  fmap biject mb =
    case mb of
      Just b -> Just ((biTo biject) b)
      Nothing -> Nothing

useFmap :: Bool
useFmap = FN.fmap biject1 (Just True) == Just One

useFmapSym :: Bool
useFmapSym = (biject1 FN.<$> (Just True)) == Just One -- see also >$< >$ $<

-- invariant monoidal functor (invertible.monoidal), which is like applicative for invariant functors
instance MN.Monoidal Maybe where
  unit = Nothing
  ma >*< mb =
    case (ma, mb) of
      (Nothing, _) -> Nothing
      (_, Nothing) -> Nothing
      (Just a, Just b) -> Just (a,b)

-- >*<, liftI2
-- >*<<, >*<<<, *<, >*, unit, fromMaybe, rgt
-- monoidalt >|<

-- How does bijection and free relate to MN.Monoidal? How does Path instantiate and use these?

---------------------------------- using path combining operators

type PathParser = Path

(</>) :: PathParser a -> PathParser b -> PathParser (a, b)
(</>) = (>*<)

pathParams :: Route (Int, Double) -- use </> to combine parameter parsers
pathParams = routePath ((parameter :: Path Int) </> (parameter :: Path Double))

(>/>) :: PathParser () -> PathParser a -> PathParser a
(>/>) = (*<)
(</<) :: PathParser a -> PathParser () -> PathParser a
(</<) = (>*)

pathParam :: Route (Double) -- use >/> to ignore left parser output
pathParam = routePath ("aval" >/> (parameter :: Path Double))

(</>>) :: PathParser a -> PathParser (b, c) -> PathParser (a, b, c)
(</>>) = (>*<<)
(</>>>) :: PathParser a -> PathParser (b, c, d) -> PathParser (a, b, c, d)
(</>>>) = (>*<<<)

pathParam3 :: Route (Double, Int, Double) -- build up in parts
pathParam3 = 
  routePath
    ((parameter :: Path Double)
     >*<<
     ((parameter :: Path Int) </> (parameter :: Path Double)))
    
infix 3 |/|
(|/|) :: PathParser a -> PathParser b -> PathParser (Either a b)
(|/|) = (>|<)

pathEither1 :: Route (Either Int Double)  -- either int or double param
pathEither1 =
  routePath
    ((parameter :: Path Int)
     |/|
     (parameter :: Path Double))

pathMaybe :: PathParser a -> PathParser (Maybe a)
pathMaybe p = I.rgt >$< (unit |/| p)

pathMaybe1 :: Route (Maybe Int)  -- attempt to recognize int (empty segment means nothing?)
pathMaybe1 = routePath (pathMaybe (parameter :: Path Int))

infix 3 =/=
(=/=) :: Eq a => a -> PathParser a -> PathParser a
(=/=) a p = I.fromMaybe a >$< pathMaybe p

pathMaybeDefault :: Route Int  -- attempt to recognize int, default to 10 if missing
pathMaybeDefault = routePath (10 =/= (parameter :: Path Int))

----------------------- defining reusable primitives
-- controller.paths

-- controller.excerpt

-- conrolller.web

-- action.route

------------------------ other path heleprs
-- js helpers

-- swagger helpers

-- Path module types
