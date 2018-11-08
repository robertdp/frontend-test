module Control.App where

import Prelude

import Affjax as Affjax
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Control.Language.Fetch (class MonadFetch, FetchError(..))
import Control.Language.Storage (class MonadStorage)
import Control.Monad.Except (runExcept)
import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Data.Bifunctor (lmap)
import Data.Either (Either(..), hush)
import Data.Maybe (Maybe, fromMaybe)
import Data.Sale (Sale)
import Data.Sale.Favorites (FavoriteSales)
import Data.Sale.Favorites as Favorites
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Foreign.Generic (decodeJSON, encodeJSON)
import Web.HTML (window)
import Web.HTML.Window as Window
import Web.Storage.Storage (Storage)
import Web.Storage.Storage as Storage


newtype Config = Config { baseURL :: String }

newtype App a = App (ReaderT Config Aff a)

derive newtype instance functorApp :: Functor App
derive newtype instance applyApp :: Apply App
derive newtype instance applicativeApp :: Applicative App
derive newtype instance bindApp :: Bind App
derive newtype instance monadApp :: Monad App
derive newtype instance monadEffectApp :: MonadEffect App
derive newtype instance monadAffApp :: MonadAff App
derive newtype instance monadAskApp :: MonadAsk Config App
derive newtype instance monadReaderApp :: MonadReader Config App

run :: forall a. Config -> App a -> Effect Unit
run config (App app) = launchAff_ $ runReaderT app config

instance monadFetchSalesApp :: MonadFetch Unit (Array Sale) App where
  fetch _ = do
    Config { baseURL } <- ask
    res <- liftAff $ Affjax.get ResponseFormat.string $ baseURL <> "/sales.json"
    pure $ case res.status, res.body of
      StatusCode 200, Right body ->
        decodeJSON body
          # runExcept
          # lmap (FailedDecode <<< show)

      StatusCode 404, _ ->
        Left NotFound

      _, Left error ->
        Affjax.printResponseFormatError error
          # UnexpectedFormat
          # Left

      StatusCode status, _ ->
        UnexpectedStatus status
          # Left

withLocalStorage :: forall m a. MonadEffect m => (Storage -> Effect a) -> m a
withLocalStorage f = liftEffect do
  localStorage <- Window.localStorage =<< window
  f localStorage

instance monadStorageFavoriteSalesApp :: MonadStorage FavoriteSales App where
  store favs = withLocalStorage $ Storage.setItem "favoriteSales" (encodeJSON favs)

  retrieve = do
    json <- withLocalStorage $ Storage.getItem "favoriteSales"
    pure $ decode json
    where
      decode :: Maybe String -> FavoriteSales
      decode value =
        value
          >>= decodeJSON
          >>> runExcept
          >>> hush
            # fromMaybe Favorites.empty
