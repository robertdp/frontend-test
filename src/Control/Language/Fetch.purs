module Control.Language.Fetch where

import Prelude

import Data.Either (Either)
import Foreign.Class (class Decode)


class Monad r <= MonadFetch r where
  fetch :: forall a. Decode a => URL -> r (FetchResult a)

type URL = String

type FetchResult = Either FetchError

data FetchError
  = NotFound
  | FailedDecode String
  | UnexpectedStatus Int
  | UnexpectedFormat String
