module Control.App where

import Prelude

import Affjax as Affjax
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Control.Language.Fetch (class MonadFetch, FetchError(..))
import Control.Monad.Except (runExcept)
import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT, ask, runReaderT)
import Data.Bifunctor (bimap)
import Data.Either (Either(..))
import Data.Sale (Sale)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect)
import Foreign.Generic (decodeJSON)


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

launch :: forall a. App a -> Config -> Effect Unit
launch (App app) = launchAff_ <<< runReaderT app

instance monadFetchSalesApp :: MonadFetch Unit (Array Sale) App where
  fetch _ = do
    Config { baseURL } <- ask
    res <- liftAff $ Affjax.get ResponseFormat.string $ baseURL <> "/sales.json"
    pure $ case res.status, res.body of
      StatusCode 200, Right body ->
        decodeJSON body
          # runExcept
          # bimap (FailedDecode <<< show) identity
      StatusCode 404, _ ->
        Left NotFound
      _, Left error ->
        Affjax.printResponseFormatError error
          # UnexpectedFormat
          # Left
      StatusCode status, _ ->
        UnexpectedStatus status
          # Left

