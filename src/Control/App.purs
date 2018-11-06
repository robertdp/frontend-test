module Control.App where

import Prelude

import Control.Language.Fetch (class MonadFetch)
import Control.Monad.Reader (class MonadAsk, class MonadReader, ReaderT)
import Data.Sale (Sale)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect)


newtype Config = Config Unit

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

instance monadFetchSalesApp :: MonadFetch (Array Sale) App where
  fetch _ = pure $ pure $ []