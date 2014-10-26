module Order
    ( Order(..),
      get_date
    ) where

import Data.Time.Calendar
import Data.Time
import System.Locale

data Order = Order  { year :: String,
                      month :: String,
                      day :: String,
                      sym :: String,
                      position :: String,
                      shares :: String
                    } deriving (Show)
get_date :: Order -> Day
get_date ord = readTime defaultTimeLocale "%m/%d/%Y" (month ord ++ "/" ++ day ord ++ "/" ++ year ord) :: Day

