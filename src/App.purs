module App where

import Prelude

import Control.App (Config)
import Control.App as App
import Control.Language.Storage (retrieve)
import Data.Sale.Favorites as FavoriteSales
import Effect.Class (liftEffect)
import Network.RemoteData as RemoteData
import React.Basic as React
import React.Basic.DOM (text)

component :: React.Component { config :: Config }
component = React.component { displayName: "App", initialState, receiveProps, render }
  where
    initialState =
      { sales: RemoteData.NotAsked
      , favorites: FavoriteSales.empty
      }

    receiveProps { props, setState } = App.run props.config do
      favorites <- retrieve
      liftEffect $ setState _ { favorites = favorites }
      pure unit

    render _ = text "App"
