module Data.Sale where

import Prelude

import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Int as Int
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype, unwrap)
import Data.String (Pattern(..), Replacement(..))
import Data.String as String
import Data.Tuple (Tuple(..))
import Data.Tuple as Tuple
import Foreign (F, Foreign)
import Foreign.Class (class Decode, class Encode, decode)
import Foreign.Generic (defaultOptions, genericDecode, genericEncode)
import Foreign.Index (hasOwnProperty, index) as Foreign
import Foreign.Keys (keys) as Foreign
import Math as Math


newtype Sale = Sale
  { id :: SaleID
  , name :: String
  , description :: String
  , images ::
    { url_template :: String
    , available :: SaleImage
    }
  , lifetime ::
    { begins_at :: String
    , ends_at :: String
    }
  }

newtype SaleImage = SaleImage (Map String { ratios :: Array Number })

derive instance genericSaleImage :: Generic SaleImage _
derive instance newtypeSaleImage :: Newtype SaleImage _

instance decodeSaleImage :: Decode SaleImage where
  decode a = do
    fields <- Foreign.keys a
    image <- Array.foldM (\map field -> insert field map) Map.empty fields
    pure $ SaleImage image
      where
        insert :: String -> Map String { ratios :: Array Number } -> F (Map String { ratios :: Array Number })
        insert field map = do
          value <- Foreign.index a field
          decoded <- decodeRatios value
          if Foreign.hasOwnProperty field a
            then pure $ Map.insert field decoded map
            else pure $ map

        decodeRatios :: Foreign -> F { ratios :: Array Number }
        decodeRatios b = Foreign.index b "ratios" >>= decode <#> { ratios: _ }


derive instance genericSale :: Generic Sale _

instance decodeSale :: Decode Sale where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }

newtype SaleID = SaleID String

derive newtype instance eqSaleID :: Eq SaleID
derive newtype instance ordSaleID :: Ord SaleID

derive instance genericSaleID :: Generic SaleID _
derive instance newtypeSaleID :: Newtype SaleID _

instance decodeSaleID :: Decode SaleID where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }

instance encodeSaleID :: Encode SaleID where
  encode = genericEncode $ defaultOptions { unwrapSingleConstructors = true }


getImageURL :: Int -> Int -> String -> Sale -> Maybe String
getImageURL _ 0 _ _ = Nothing -- no division by zero allowed!
getImageURL width height name (Sale sale) = do
  image <- Map.lookup name $ unwrap sale.images.available
  let
    idealRatio = (Int.toNumber width) / (Int.toNumber height)
    closestRatio =
      image.ratios
        <#> (\ratio -> Tuple ratio (Math.abs $ idealRatio - ratio))
          # Array.sortWith Tuple.snd
          # Array.head
        <#> Tuple.fst
  closestRatio <#> \ratio ->
    sale.images.url_template
      # String.replace (Pattern "{NAME}") (Replacement "default")
      # String.replace (Pattern "{RATIO}") (Replacement $ show ratio)
      # String.replace (Pattern "{WIDTH}") (Replacement $ show width)
