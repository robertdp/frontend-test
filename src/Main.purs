module Main where

import Prelude

import App as App
import Control.App (Config(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic as React
import React.Basic.DOM as DOM
import Web.DOM.NonElementParentNode (NonElementParentNode, getElementById)


config :: Config
config = Config { baseURL: "/data" }

main :: Effect Unit
main = do
  container <- getElementById "app" =<< document
  case container of
    Nothing -> throw "Container element not found."
    Just c  ->
      let app = React.element App.component { config }
      in DOM.render app c



foreign import document :: Effect NonElementParentNode
