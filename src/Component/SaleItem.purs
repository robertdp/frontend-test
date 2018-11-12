module Component.SaleItem where

import Prelude hiding (div)

import Data.DateTime (DateTime)
import Data.Either (fromRight)
import Data.Formatter.DateTime (formatDateTime)
import Data.JSDate as JSDate
import Data.Maybe (fromJust, fromMaybe)
import Data.Sale (Sale(..), SaleID)
import Data.Sale as Sale
import Effect (Effect)
import Effect.Unsafe (unsafePerformEffect)
import Partial.Unsafe (unsafePartial)
import React.Basic as React
import React.Basic.DOM (button, css, div, i, p, span, text)
import React.Basic.Events as Events


type SaleItemProps =
  { sale :: Sale
  , addFavorite :: SaleID -> Effect Unit
  , removeFavorite :: SaleID -> Effect Unit
  , isFavorite :: SaleID -> Boolean
  }

component :: React.Component SaleItemProps
component = React.stateless { displayName: "SaleItem", render }
  where
    render props@{ sale: Sale sale } =
      let isFavorited = props.isFavorite sale.id
      in
      div
        { className: "w-full flex mb-6"
        , children:
          [ div
            { className: "h-auto w-64 flex-none bg-cover bg-center rounded-t-none rounded-l text-center overflow-hidden"
            , style: css
              { backgroundImage: fromMaybe "" $ Sale.getImageURL 256 200 "default" props.sale <#> \image -> "url('" <> image <> "')"
              }
            , children: []
            }
          , div
            { className: "w-full border-r border-b border-l-0 border-t border-grey-light bg-white rounded-b-none rounded-r p-4 flex flex-col justify-between leading-normal"
            , children:
              [ div
                { className: "mb-8"
                , children:
                  [ p
                    { className: "text-sm text-grey-dark flex items-center"
                    , children: [ text $ "Ends at " <> formatTime sale.lifetime.ends_at <> " on " <> formatDate sale.lifetime.ends_at ]
                    }
                  , div
                    { className: "text-black font-bold text-xl mb-2"
                    , children: [ text sale.name ]
                    }
                  , p
                    { className: "text-grey-darker text-xs"
                    , children: [ text sale.description ]
                    }
                  ]
                }
              , div
                { className: "flex items-center text-grey"
                , children:
                  [ button
                    { className: "bg-white hover:text-red py-2 px-4 rounded-full mr-2"
                    , children:
                      [ i
                        { className:
                          if isFavorited
                            then "fas fa-heart text-red"
                            else "far fa-heart"
                        , children: []
                        }
                      ]
                    , onClick: Events.handler_ do
                      if isFavorited
                        then props.removeFavorite sale.id
                        else props.addFavorite sale.id
                    }
                  ,  if isFavorited
                    then span { className: "text-sm", children: [ text "Added to favorites" ] }
                    else React.empty
                  ]
                }
              ]
            }
          ]
        }

unsafeToDateTime :: String -> DateTime
unsafeToDateTime =
  unsafePartial $ fromJust <<< JSDate.toDateTime <<< unsafePerformEffect <<< JSDate.parse

unsafeFormatDateTime :: String -> DateTime -> String
unsafeFormatDateTime pattern datetime =
  unsafePartial $ fromRight $ formatDateTime pattern datetime

formatDate :: String -> String
formatDate =
    unsafeFormatDateTime "MMMM D, YYYY" <<< unsafeToDateTime

formatTime :: String -> String
formatTime =
    unsafeFormatDateTime "hh:mm a" <<< unsafeToDateTime
