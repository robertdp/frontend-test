module Data.Sale.Favorites
  ( FavoriteSales
  , empty
  , insert
  , delete
  , member
  )
  where

import Prelude

import Data.Newtype (class Newtype)
import Data.Newtype as Newtype
import Data.Sale (SaleId)
import Data.Set (Set)
import Data.Set as Set
import Foreign.Class (class Decode, class Encode, decode, encode)


newtype FavoriteSales = FavoriteSales (Set SaleId)

derive instance newtypeFavoriteSales :: Newtype FavoriteSales _

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

empty :: FavoriteSales
empty = FavoriteSales Set.empty

insert :: SaleId -> FavoriteSales -> FavoriteSales
insert = Newtype.over FavoriteSales <<< Set.insert

delete :: SaleId -> FavoriteSales -> FavoriteSales
delete = Newtype.over FavoriteSales <<< Set.delete

member :: SaleId -> FavoriteSales -> Boolean
member id (FavoriteSales favs) = Set.member id favs
