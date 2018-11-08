module App where

import Prelude

import Control.App (App(..), Config)
import Control.App as App
import Control.Language.Fetch (FetchError, fetch)
import Control.Language.Storage (retrieve, store)
import Data.Either (Either)
import Data.Sale (Sale, SaleId(..))
import Data.Sale.Favorites (FavoriteSales(..))
import Data.Sale.Favorites as Favorites
import Data.Set as Set
import Effect.Class (liftEffect)
import Effect.Console (log)
import Foreign.Generic (encodeJSON)
import React.Basic as React
import React.Basic.DOM (text)
import Unsafe.Coerce (unsafeCoerce)

component :: React.Component { config :: Config }
component = React.component { displayName: "App", initialState, receiveProps, render }
  where
    initialState = {}
    receiveProps { props } = App.run props.config do
      (retrieve :: App FavoriteSales) >>= (encodeJSON >>> show >>> log >>> liftEffect)
      store (FavoriteSales $ Set.singleton $ SaleId "test")
      pure unit
    render _ = text "App"
