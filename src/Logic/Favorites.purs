module Logic.Favorites where

import Prelude

import Control.Language.Storage (class MonadStorage, retrieve, store)
import Data.Sale (SaleID)
import Data.FavoriteSales (FavoriteSales, delete, insert)


getFavorites :: forall m. MonadStorage FavoriteSales m => m FavoriteSales
getFavorites = retrieve

addFavorite :: forall m. MonadStorage FavoriteSales m => SaleID -> FavoriteSales -> m FavoriteSales
addFavorite sale favs = store favorites *> pure favorites
  where
    favorites = insert sale favs

removeFavorite :: forall m. MonadStorage FavoriteSales m => SaleID -> FavoriteSales -> m FavoriteSales
removeFavorite sale favs = store favorites *> pure favorites
  where
    favorites = delete sale favs
