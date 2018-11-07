module Main where

import Prelude

import App as App
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic as React
import React.Basic.DOM as DOM
import Web.DOM.NonElementParentNode (NonElementParentNode, getElementById)


foreign import document :: Effect NonElementParentNode

main :: Effect Unit
main = do
  container <- getElementById "app" =<< document
  case container of
    Nothing -> throw "Container element not found."
    Just c  ->
      let app = React.element App.component {}
      in DOM.render app c
