module Component.SaleContainer where

import Prelude hiding (div)

import Component.SaleItem as SaleItem
import Control.App (Config)
import Control.App as App
import Control.Language.Fetch (FetchError)
import Data.Array as Array
import Data.FavoriteSales (FavoriteSales)
import Data.FavoriteSales as FavoriteSales
import Data.Foldable (traverse_)
import Data.Sale (Sale(..), SaleID)
import Effect (Effect)
import Effect.Class (liftEffect)
import Logic.Favorites as Favorites
import Logic.Sales as Sales
import Network.RemoteData (RemoteData(..))
import Network.RemoteData as RemoteData
import React.Basic (StateUpdate(..))
import React.Basic as React
import React.Basic.DOM (div, form, i, input, label, p, span, span_, text)


component :: React.Component { config :: Config }
component = React.createComponent "SaleContainer"

data Action
  = UpdateFavorites FavoriteSales
  | UpdateSales (RemoteData FetchError (Array Sale))
  | ToggleFavorite SaleID
  | ToggleFilter

data SaleFilter
  = AllSales
  | OnlyFavorites

saleContainer :: { config :: Config } -> React.JSX
saleContainer = React.make component { initialState, didMount, update, render }
  where
    initialState =
      { sales: RemoteData.NotAsked :: RemoteData FetchError (Array Sale)
      , favorites: FavoriteSales.empty
      , filter: AllSales
      }

    didMount self = do
      React.send self $ UpdateSales RemoteData.Loading
      traverse_ (App.run self.props.config)
        [ do
            favorites <- Favorites.getFavorites
            liftEffect $ React.send self $ UpdateFavorites favorites
        , do
            sales <- RemoteData.fromEither <$> Sales.fetchActiveSales
            liftEffect $ React.send self $ UpdateSales sales
        ]

    update self = case _ of
      ToggleFilter ->
        Update $ self.state
          { filter = case self.state.filter of
              AllSales -> OnlyFavorites
              OnlyFavorites -> AllSales
          }

      ToggleFavorite id ->
        SideEffects \s -> App.run s.props.config do
          favs <- if FavoriteSales.member id s.state.favorites
            then Favorites.removeFavorite id s.state.favorites
            else Favorites.addFavorite id s.state.favorites
          liftEffect $ React.send s $ UpdateFavorites favs

      UpdateFavorites favs ->
        Update $ self.state { favorites = favs }

      UpdateSales sales ->
        Update $ self.state { sales = sales }


    render self =
      div
        { className: "container mx-auto max-w-lg flex flex-wrap justify-center m-10"
        , children:
          append [ renderFilter ]
            $ case self.state.sales of
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
                    { className: "w-full flex"
                    , children:
                      [ span
                        { className: "mx-auto text-grey"
                        , children: [ text "An unexpected error has occured. Please try reloading the page." ]
                        }
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
                      , onClick: React.capture_ self ToggleFilter
                      }
                    , span_ [ text "Show only favorited sales"]
                    ]
                  }
                ]
              }

          filterSales = case self.state.filter of
              AllSales -> identity
              OnlyFavorites -> Array.filter (\(Sale sale) -> isFavorite sale.id)

          renderSale sale = SaleItem.saleItem { sale, isFavorite, toggleFavorite }

          toggleFavorite :: SaleID -> Effect Unit
          toggleFavorite id = React.send self $ ToggleFavorite id

          isFavorite :: SaleID -> Boolean
          isFavorite id = FavoriteSales.member id self.state.favorites
