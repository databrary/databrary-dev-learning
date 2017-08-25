{-# LANGUAGE MultiParamTypeClasses #-}
module Lib5
where

import Control.Monad.Reader (MonadReader(..), ReaderT(..), reader, withReaderT, Reader, runReader)

class Has a c where
  view :: c -> a

data Record = Record { field1 :: Int }

-- (Has a c) => ReaderT * c m a
peek :: (MonadReader c m, Has a c) => m a   -- m is reader monad; c is val in reader context; a is component of c
peek = reader view

-- define some reader based action
rdrAct :: Reader Int String
rdrAct = do
  v <- ask
  return (show v)

-- run reader
runSimple :: Bool
runSimple =
  "10" == runReader rdrAct 10


-- define some readert based action and run it
-- rdrAct2 :: ReaderT * Int IO String
-- rdrAct2 = do
--  v <- ask
--  return (show v)

-- define some monadreader based action and run it

-- define a monadreaader action over a Has Record which runs peek and run it
