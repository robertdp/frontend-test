module Data.FavoriteSales
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
import Data.Sale (SaleID)
import Data.Set (Set)
import Data.Set as Set
import Foreign.Class (class Decode, class Encode, decode, encode)


newtype FavoriteSales = FavoriteSales (Set SaleID)

derive instance newtypeFavoriteSales :: Newtype FavoriteSales _

instance decodeFavoriteSales :: Decode FavoriteSales where
  decode = decode >>> map fromArray
    where
      fromArray :: Array SaleID -> FavoriteSales
      fromArray = Set.fromFoldable >>> Newtype.wrap

instance encodeFavoriteSales :: Encode FavoriteSales where
  encode = toArray >>> encode
    where
      toArray :: FavoriteSales -> Array SaleID
      toArray = Newtype.unwrap >>> Set.toUnfoldable

empty :: FavoriteSales
empty = FavoriteSales Set.empty

insert :: SaleID -> FavoriteSales -> FavoriteSales
insert = Newtype.over FavoriteSales <<< Set.insert

delete :: SaleID -> FavoriteSales -> FavoriteSales
delete = Newtype.over FavoriteSales <<< Set.delete

member :: SaleID -> FavoriteSales -> Boolean
member id (FavoriteSales favs) = Set.member id favs
