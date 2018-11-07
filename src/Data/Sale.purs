module Data.Sale where

import Prelude
import Data.Generic.Rep (class Generic)
import Foreign.Class (class Decode)
import Foreign.Generic (defaultOptions, genericDecode)


newtype Sale = Sale { name :: String }

derive instance genericSales :: Generic Sale _

instance decodeSale :: Decode Sale where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }
