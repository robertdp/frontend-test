module Main where

import Prelude

import App as App
import Control.App (Config(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic as React
import React.Basic.DOM as DOM
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window as Window


config :: Config
config = Config { baseURL: "/data" }

main :: Effect Unit
main = do
  container <- getElementById "app" =<< (map toNonElementParentNode $ Window.document =<< window)
  case container of
    Nothing -> throw "Container element not found."
    Just c  ->
      let app = React.element App.component { config }
      in DOM.render app c
