{-# LANGUAGE OverloadedStrings #-}
module Lib
where

import Web.Route.Invertible

-- web-inv-route

routeGet :: Route () -- match any request that is a GET request
routeGet = routeMethod GET

pathStatic :: Route () -- match one segment with "aval"
pathStatic = routePath "aval"

pathParam :: Route Int -- match one segment with wildcard, converting to int
pathParam = routePath (parameter :: Path Int)

getStatic :: RouteAction () String -- takes no params, returns string result
getStatic =
  routeMethod GET *< routePath "aval"
    `RouteAction` \() -> "get a val"

getThing :: RouteAction Int String -- takes an int param, returns string result
getThing =
  routeMethod GET *< routePath ("thing" *< parameter)
    `RouteAction` \i -> "get thing" ++ show i

-- build a route map
routeMap :: RouteMap String
routeMap = routes [ routeCase getStatic, routeCase getThing ]

someFunc :: IO ()
someFunc =
  putStrLn "some func"
  -- Warp.runSettings (setPort defaultSettings)
  --   (runRoute map)

-- runActionRoute :: RouteMap Action -> Application
-- runActionRoute rm req =
--   runAction (either errResp id (R.routeWai req rm)) req

-- runAction act req send = do
--   r <- act
--   send r

-- SECOND EXAMPLE:
-- invertible - Free - reified monad that allows custom interpretration of join
-- invertible - bijections, monoidal

-- THIRD EXAMPLE:
--  *< - discard left
--  monoidal functor

-- OTHER EXAMPLE:
-- from RouteAction Int String
-- to ... Response
-- to ... IO Response
-- to ... ReaderT Request IO Response
-- to ... ReaderT (Context, Request, Identity) IO Response
-- to ... Action { actionM :: ActionM Response }
-- to ... Action { authReq :: Bool, actionM :: ActionM Response }
