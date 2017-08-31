{-# LANGUAGE MultiParamTypeClasses #-}
module Lib6
where

--- monadhas pattern in identity.types
-- type MonadHas a c m = (Functor m, Applicative m, MonadReader c m, Has a c) -- isn't Functor redundant?


-- current usage of MonadHas?
