module App where

import Prelude

import Control.App (Config)
import Control.App as App
import Control.Language.Fetch (FetchError, fetch)
import Control.Language.Storage (retrieve, store)
import Data.Sale (Sale, SaleId)
import Data.Sale.Favorites as FavoriteSales
import Effect (Effect)
import Effect.Class (liftEffect)
import Foreign.Generic (encodeJSON)
import Network.RemoteData (RemoteData)
import Network.RemoteData as RemoteData
import React.Basic as React
import React.Basic.DOM (text)

component :: React.Component { config :: Config }
component = React.component { displayName: "App", initialState, receiveProps, render }
  where
    initialState =
      { sales: RemoteData.Loading :: RemoteData FetchError (Array Sale)
      , favorites: FavoriteSales.empty
      }

     -- this is to avoid infinite loops. see https://github.com/lumihq/purescript-react-basic/issues/52
    receiveProps { isFirstMount: false} = pure unit
    receiveProps { props, setState } = do
      App.run props.config do
        favorites <- retrieve
        liftEffect $ setState _ { favorites = favorites }
      App.run props.config do
        salesResponse <- RemoteData.fromEither <$> fetch unit
        liftEffect $ setState _ { sales = salesResponse }

    render { props, state, setState } =
      let
        addFavorite :: SaleId -> Effect Unit
        addFavorite id = App.run props.config do
          let favs = FavoriteSales.insert id state.favorites
          store favs
          liftEffect $ setState _ { favorites = favs}

        removeFavorite :: SaleId -> Effect Unit
        removeFavorite id = App.run props.config do
          let favs = FavoriteSales.delete id state.favorites
          store favs
          liftEffect $ setState _ { favorites = favs}

        isFavorite :: SaleId -> Boolean
        isFavorite id = FavoriteSales.member id state.favorites

      in
        text $ encodeJSON state.favorites
