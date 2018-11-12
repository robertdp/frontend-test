module Component.SaleContainer where

import Prelude hiding (div)

import Component.SaleItem as SaleItem
import Control.App (Config)
import Control.App as App
import Control.Language.Fetch (FetchError)
import Data.Array as Array
import Data.FavoriteSales as FavoriteSales
import Data.Sale (Sale(..), SaleID)
import Effect (Effect)
import Effect.Class (liftEffect)
import Logic.Favorites as Favorites
import Logic.Sales as Sales
import Network.RemoteData (RemoteData(..))
import Network.RemoteData as RemoteData
import React.Basic as React
import React.Basic.DOM (div, form, i, input, label, p, span, span_, text)
import React.Basic.Events as Events


data SaleFilter
  = AllSales
  | OnlyFavorites

component :: React.Component { config :: Config }
component = React.component { displayName: "SaleContainer", initialState, receiveProps, render }
  where
    initialState =
      { sales: RemoteData.NotAsked :: RemoteData FetchError (Array Sale)
      , favorites: FavoriteSales.empty
      , filter: AllSales
      }

    -- this is to avoid infinite loops. see https://github.com/lumihq/purescript-react-basic/issues/52
    receiveProps { isFirstMount: false} = pure unit
    receiveProps { props, setState } = do
      App.run props.config do
        favorites <- Favorites.getFavorites
        liftEffect $ setState _ { favorites = favorites }
      App.run props.config do
        liftEffect $ setState _ { sales = RemoteData.Loading }
        salesResponse <- Sales.fetchActiveSales <#> RemoteData.fromEither
        liftEffect $ setState _ { sales = salesResponse }

    render { props, state, setState } =
      div
        { className: "container mx-auto max-w-lg flex flex-wrap justify-center m-10"
        , children:
          append [ renderFilter ]
            $ case state.sales of
                Loading ->
                  [ p
                    { className: "w-full flex"
                    , children:
                      [ i
                        { className: "fas fa-spinner fa-spin text-grey text-4xl mx-auto"
                        , children: []
                        }
                      ]
                    }
                  ]
                Success sales ->
                  case filterSales sales of
                    [] ->
                      pure $ div
                        { className: "text-grey text-base w-full flex"
                        , children:
                          [ span
                            { className: "mx-auto"
                            , children: [ text "There are no sales to show." ]
                            }
                          ]
                        }
                    sales' ->
                      map renderSale sales'
                _ ->
                  [ p
                    { className: "w-full"
                    , children:
                      [ text "An unexpected error has occured. Please try reloading the page."
                      ]
                    }
                  ]
        }

        where
          renderFilter =
            form
              { className: "max-w-xs text-sm mb-10"
              , children:
                [ label
                  { children:
                    [ input
                      { className: "mr-2"
                      , "type": "checkbox"
                      , onClick: Events.handler_ $ setState \s -> s { filter = switchFilter s.filter }
                      }
                    , span_ [ text "Show only favorited sales"]
                    ]
                  }
                ]
              }

          switchFilter = case _ of
              AllSales -> OnlyFavorites
              OnlyFavorites -> AllSales

          filterSales = case state.filter of
              AllSales -> identity
              OnlyFavorites -> Array.filter (\(Sale sale) -> isFavorite sale.id)

          renderSale sale = React.element SaleItem.component saleProps
            where
              saleProps =
                { sale
                , isFavorite
                , addFavorite
                , removeFavorite
                }

          addFavorite :: SaleID -> Effect Unit
          addFavorite id = App.run props.config do
            favs <- Favorites.addFavorite id state.favorites
            liftEffect $ setState _ { favorites = favs}

          removeFavorite :: SaleID -> Effect Unit
          removeFavorite id = App.run props.config do
            favs <- Favorites.removeFavorite id state.favorites
            liftEffect $ setState _ { favorites = favs}

          isFavorite :: SaleID -> Boolean
          isFavorite id = FavoriteSales.member id state.favorites
