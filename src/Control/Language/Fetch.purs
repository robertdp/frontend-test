module Control.Language.Fetch where

import Prelude
import Network.RemoteData (RemoteData)


class Monad r <= MonadFetch a b r | b -> a where
  fetch :: a -> r (RemoteData FetchError b)

data FetchError
  = NotFound
  | FailedDecode String
  | UnexpectedStatus Int
