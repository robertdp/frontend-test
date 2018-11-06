module Control.Language.Storage where

import Prelude


class (Monad r, Monoid a) <= MonadStorage a r where
  store :: a -> r Unit
  retrieve :: r a
  