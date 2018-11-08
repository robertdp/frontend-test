module Data.Sale.Image where

import Prelude
import Data.Generic.Rep (class Generic)
import Foreign.Class (class Decode)
import Foreign.Generic (defaultOptions, genericDecode)


newtype SaleImage = SaleImage
  { url_template :: String
  , available :: { default :: { ratios :: Array Number } }
  }

derive instance genericSaleImage :: Generic SaleImage _

instance decodeSaleImage :: Decode SaleImage where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }
