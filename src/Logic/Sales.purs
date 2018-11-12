module Logic.Sales where

import Prelude

import Control.Language.Fetch (class MonadFetch, FetchResult, fetch)
import Control.Language.Time (class MonadTime, now)
import Control.MonadZero (guard)
import Data.Array as Array
import Data.DateTime (DateTime)
import Data.JSDate as JSDate
import Data.Maybe (fromMaybe)
import Data.Sale (Sale(..))
import Effect.Unsafe (unsafePerformEffect)


fetchActiveSales :: forall m. MonadFetch m => MonadTime m => m (FetchResult (Array Sale))
fetchActiveSales = do
  (sales :: FetchResult (Array Sale)) <- fetch "/sales.json"
  time <- now
  pure $ map (filterActiveAt time) sales
    where
      filterActiveAt :: DateTime -> Array Sale -> Array Sale
      filterActiveAt now = Array.filter \(Sale sale) -> fromMaybe false do
          begins_at <- toDateTime sale.lifetime.begins_at
          ends_at <- toDateTime sale.lifetime.ends_at
          guard $ begins_at < now && ends_at > now
          pure true

      toDateTime = JSDate.parse >>> unsafePerformEffect >>> JSDate.toDateTime

