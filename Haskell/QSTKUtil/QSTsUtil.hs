module QSTKUtil.QSTsUtil
  (
    getSharpeRatio,
    daily
  ) where

import QSTKUtil.Date
import QSTKUtil.Math.Statistics

getSharpeRatio :: [Double] -> Double
getSharpeRatio r = sqrt 252 * ((mean r) / (stddev r))

daily :: [Double] -> [Double]
daily (_:[]) = []
daily all@(x:_) = if x == 0.0
                  then [0.0] ++ daily (tail all)
                  else [((head (tail all)) / x  - 1)] ++ daily (tail all)