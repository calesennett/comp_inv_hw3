module Lib.DataParser
  (
    readFrom,
    slice
  ) where

import System.Locale
import Data.Time
import Data.Time.Format
import Data.List.Split
import Control.Monad.IO.Class
import Data.List
import QSTKUtil.Date
import qualified Data.Map as Map
import qualified Data.Vector as V
import Data.Maybe

slice :: (Eq a) => Int -> Int -> [a] -> [a]
slice from to xs = take (to - from + 1) (drop from xs)

--params :: ticker, start date, end date
readFrom :: Day -> Day -> Int -> Int -> String -> IO (String, [String])
readFrom sd ed lb lf t =  do
                    all <- readFile ("Lib/Data/" ++ t ++ ".csv")
                    let prices =  zip dates (tail $ map last $ map (splitOn ",") $ lines all)
                                where dates = (tail $ map head $ map (splitOn ",") $ lines all)
                    let start = fromMaybe 0 (elemIndex ed $ map (parseStock) $ map fst prices) - lb
                    let end = fromMaybe 0 (elemIndex sd $ map (parseStock) $ map fst prices) + lf
                    let prices_from = slice start end (map snd prices) --filter (\x -> parseStock (fst x) < ed && parseStock (fst x) >= sd) prices
                    return (t, reverse $ prices_from)
