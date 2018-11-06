module Control.Monad.Effect.Launch where

import Prelude
import Data.Identity (Identity)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)


class Monad m <= MonadLaunch m where
  launch :: forall a. m a -> Effect Unit

instance monadLaunchIdentity :: MonadLaunch Identity where
  launch _ = pure unit

instance monadLaunchEffect :: MonadLaunch Effect where
  launch = void

instance monadLaunchAff :: MonadLaunch Aff where
  launch = launchAff_