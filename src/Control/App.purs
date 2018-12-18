module Control.App where

import Prelude

import Affjax as Affjax
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Control.Language.Fetch (class MonadFetch, FetchError(..))
import Control.Language.Storage (class MonadStorage)
import Control.Language.Time (class MonadTime)
import Control.Monad.Except (runExcept, throwError)
import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Data.Bifunctor (lmap)
import Data.Either (Either(..), hush)
import Data.FavoriteSales (FavoriteSales)
import Data.FavoriteSales as FavoriteSales
import Data.JSDate as JSDate
import Data.Maybe (Maybe, fromJust, fromMaybe)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Foreign.Generic (decodeJSON, encodeJSON)
import Partial.Unsafe (unsafePartial)
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

instance monadFetchSalesApp :: MonadFetch App where
  fetch url = do
    Config { baseURL } <- ask
    res <- liftAff $ Affjax.get ResponseFormat.string $ baseURL <> url
    pure case res.status, res.body of
      StatusCode 200, Right body ->
        handleDecode body

      StatusCode 404, _ ->
        Left NotFound

      _, Left error ->
        throwError $ UnexpectedFormat $ Affjax.printResponseFormatError error

      StatusCode status, _ ->
        Left $ UnexpectedStatus status

    where
      handleDecode = decodeJSON >>> runExcept >>> lmap (FailedDecode <<< show)


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
            # fromMaybe FavoriteSales.empty


instance monadTimeApp :: MonadTime App where
  now = liftEffect $ map toDateTime $ JSDate.parse "Tue Sep 27 2016 17:09:07 GMT+0900 (JST)"
    where
      toDateTime = unsafePartial $ fromJust <<< JSDate.toDateTime
