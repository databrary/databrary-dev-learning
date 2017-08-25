{-# LANGUAGE TemplateHaskell #-}
module Lib4
where

import Lib4th

-- make instances of enum
-- in the db: 
-- CREATE TYPE audit.action AS ENUM ('attempt', 'open', 'close', 'add', 'change', 'remove', 'superuser');
-- AuditAction is the general prefix and typename to use for the Haskell enum corresponding to the db enum
makeDBEnum "audit.action" "AuditAction"

-- use instances..

f1 :: ()
f1 =
  let e1 = AuditActionV1 :: AuditAction
      e2 = AuditActionV2 :: AuditAction
      k = kindOf AuditActionV1 :: String
  in ()
