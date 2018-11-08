module Data.Sale where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Sale.Image (SaleImage)
import Foreign.Class (class Decode)
import Foreign.Generic (defaultOptions, genericDecode)


newtype Sale = Sale
  { id :: SaleId
  , name :: String
  , description :: String
  , images :: SaleImage
  }

derive instance genericSale :: Generic Sale _

instance decodeSale :: Decode Sale where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }

newtype SaleId = SaleId String

derive newtype instance eqSaleId :: Eq SaleId

derive instance genericSaleId :: Generic SaleId _

instance decodeSaleId :: Decode SaleId where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }
