module Main where

import Prelude

import Component.SaleContainer as SaleContainer
import Control.App (Config(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM as DOM
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window as Window


config :: Config
config = Config { baseURL: "../data" }

main :: Effect Unit
main = do
  document <- Window.document =<< window
  container <- getElementById "app" $ toNonElementParentNode document
  case container of
    Nothing -> throw "Container element not found."
    Just c  ->
      let app = SaleContainer.saleContainer { config }
      in DOM.render app c
