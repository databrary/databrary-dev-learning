{-# LANGUAGE DataKinds, TemplateHaskell, TypeFamilies, UndecidableInstances, StandaloneDeriving, GeneralizedNewtypeDeriving #-}
module Lib
where

import Control.Arrow (first)
import Data.Hashable (Hashable(..))
import Data.Int (Int32)
import Text.Read (Read(..))

--------------  IdType type family example
type family IdType a

newtype Id a = Id { unId :: IdType a }

deriving instance Eq (IdType a) => Eq (Id a)
deriving instance Ord (IdType a) => Ord (Id a)
deriving instance Enum (IdType a) => Enum (Id a)
deriving instance Bounded (IdType a) => Bounded (Id a)
instance Hashable (IdType a) => Hashable (Id a) where
  hashWithSalt i = hashWithSalt i . unId
  hash = hash . unId

instance Show (IdType a) => Show (Id a) where
  showsPrec p (Id a) = showsPrec p a
  show (Id a) = show a
instance Read (IdType a) => Read (Id a) where
  readsPrec p s = map (first Id) $ readsPrec p s
  readPrec = Id <$> readPrec

someFunc :: IO ()
someFunc =
  putStrLn "hi"

type instance IdType Record0 = String

data Record0 = Record0
  { rcd0Id :: IdType Record0
  , rcd0Val :: Int
  }

type instance IdType Record = String

data Record = Record
  { rcdId :: Id Record
  , rcdVal :: Int
  }

createId :: ()
createId =
  let rec0Id = "abc" :: IdType Record0
      recId = Id "def" :: Id Record
      aRec0 = Record0 "abc" 1
      aRec = Record (Id "abc") 1
      _ = recId == Id "xyz"
  in ()

----------
