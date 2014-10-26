module QSTKUtil.QSDateUtil
  (
    getMonthNames,
    getYears,
    getMonths,
    getDays,
    getDaysBetween,
    getFirstDay,
    getLastDay,
    getNextOptionClose,
    getLastOptionClose,
    getNYSEoffset,
    getNYSEdays,
    getNextNYSEdays,
    getPrevNYSEday,
    ymd2epoch,
    epoch2date,
    tradeDates
  ) where

import QSTKUtil.Date
import System.Locale
import Data.Time
import Data.Time.Format

getMonthNames = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"]

getYears :: [Date] -> [Date]
getYears = undefined

getMonths :: [Date] -> Integer -> [Date]
getMonths = undefined

getDays :: [Date] -> [Date]
getDays = undefined

getDaysBetween :: Date -> Date -> [Date]
getDaysBetween = undefined

getFirstDay :: [Date] -> Date
getFirstDay = undefined

getLastDay :: [Date] -> Date
getLastDay = undefined

getNextOptionClose :: Date -> Date
getNextOptionClose = undefined

getLastOptionClose :: Date -> Date
getLastOptionClose = undefined

getNYSEoffset :: Integer -> Integer -> Date
getNYSEoffset = undefined

getNYSEdays :: Day -> Day -> IO [Day]
getNYSEdays sd ed = do
                    contents <- readFile "nyse.txt"
                    let dates = map parseNYSE $ lines contents
                    let nyseDates = [x | x <- dates, x >= sd, x <= ed]
                    return nyseDates

getNextNYSEdays :: Date -> [Date]
getNextNYSEdays = undefined

getPrevNYSEday :: Date -> Date
getPrevNYSEday = undefined

ymd2epoch :: Date -> Integer
ymd2epoch = undefined

epoch2date :: Integer -> Date
epoch2date = undefined

tradeDates :: Date -> Date -> [Date]
tradeDates = undefined
