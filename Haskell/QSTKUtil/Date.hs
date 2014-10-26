module QSTKUtil.Date
  (
    Date(..),
    --showDate,
    --stockDate,
    parseNYSE,
    parseStock
  ) where

import System.Locale
import Data.Time
import Data.Time.Format

data Date = Date {month :: Int, day :: Int, year :: Int}
            deriving (Show)

parseNYSE :: String -> Day
parseNYSE s = readTime defaultTimeLocale "%m/%d/%Y" s :: Day

parseStock :: String -> Day
parseStock s = readTime defaultTimeLocale "%Y-%m-%d" s :: Day


--showDate :: Date -> String
--showDate (Date {month = m, day = d, year = y}) = show m ++ "/" ++ show d ++ "/" ++ show y

--stockDate :: Date -> String
--stockDate (Date {month = m, day = d, year = y}) = show y ++ "-" ++ zMonth ++ "-" ++ show d
--                                                  where zMonth =  if length (show m) == 2
--                                                                  then (show m)
--                                                                  else "0" ++ show m