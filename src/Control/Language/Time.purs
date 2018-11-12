module Control.Language.Time where

import Prelude

import Data.DateTime (DateTime)


class Monad r <= MonadTime r where
  now :: r DateTime
