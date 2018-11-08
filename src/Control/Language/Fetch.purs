module Control.Language.Fetch where

import Prelude
import Data.Either (Either)


class Monad r <= MonadFetch a b r | b -> a where
  fetch :: a -> r (Either FetchError b)

data FetchError
  = NotFound
  | FailedDecode String
  | UnexpectedStatus Int
