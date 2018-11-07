module App where

import Prelude

import React.Basic as React
import React.Basic.DOM (text) as DOM

component :: React.Component {}
component = React.component { displayName: "App", initialState, receiveProps, render }
  where
    initialState = {}
    receiveProps _ = pure unit
    render _ = DOM.text "App"
