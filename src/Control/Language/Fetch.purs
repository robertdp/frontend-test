module Control.Language.Fetch where

import Prelude
import Data.Maybe (Maybe)
import Foreign.Class (class Decode)
import Type.Proxy (Proxy)


class (Monad r, Decode a) <= MonadFetch a r where
  fetch :: Proxy a -> r (Maybe a)
