module Control.Language.Storage where

import Prelude


class Monad r <= MonadStorage a r where
  store :: a -> r Unit
  retrieve :: r a
