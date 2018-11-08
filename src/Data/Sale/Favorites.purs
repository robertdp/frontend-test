module Data.Sale.Favorites where

import Prelude

import Data.Sale (SaleId)
import Data.Set (Set)
import Data.Set as Set
import Foreign.Class (class Decode, class Encode, decode, encode)


newtype FavoriteSales = FavoriteSales (Set SaleId)

instance decodeFavoriteSales :: Decode FavoriteSales where
  decode = decode >>> map fromArray
    where
      fromArray :: Array SaleId -> FavoriteSales
      fromArray = Set.fromFoldable >>> FavoriteSales

instance encodeFavoriteSales :: Encode FavoriteSales where
  encode = toArray >>> encode
    where
      toArray :: FavoriteSales -> Array SaleId
      toArray (FavoriteSales set) = Set.toUnfoldable set

