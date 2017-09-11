{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( someFunc
    ) where

import Network.HTTP.Types (ok200, Status, ResponseHeaders)
import qualified Network.Wai as Wai
import qualified Network.Wai.Handler.Warp as Warp
import Web.Route.Invertible
import qualified Web.Route.Invertible.Wai as R
import qualified Data.ByteString.Lazy.Char8 as BSC

someFunc :: IO ()
someFunc =
  -- initialize services
  -- pass services to app
  Warp.runSettings
    (Warp.setPort 8080 Warp.defaultSettings)
    app

app :: Wai.Application
app req respond =
  let routeMap :: RouteMap String
      routeMap = routes [ routeCase getStatic ]
      eAct :: Either (Status, ResponseHeaders) String
      eAct = R.routeWai req routeMap
      respStr = either (\(st, hdrs) -> "not found") id eAct
  in respond (Wai.responseLBS ok200 [] (BSC.pack respStr))

-- IO Response instead of String from route actions
-- 

getStatic :: RouteAction () String
getStatic =
  RouteAction
    (routeMethod GET *< routePath "aval")
    (\() -> "get a val")

-- web server
--   with services
--     and db
--     ... and ...
--
