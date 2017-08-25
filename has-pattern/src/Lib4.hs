{-# LANGUAGE TemplateHaskell #-}
module Lib4
where

import Lib4th

-- make instances of enum

makeDBEnum "audit.action" "AuditAction"

-- use instances..

f1 :: ()
f1 =
  let e1 = AuditActionV1 :: AuditAction
      e2 = AuditActionV2 :: AuditAction
      k = kindOf AuditActionV1 :: String
  in ()
