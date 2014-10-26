import qualified QSTKUtil.QSTsUtil as TSU
import qualified QSTKUtil.QSDateUtil as DU
import qualified Lib.DataParser as DP
import qualified QSTKUtil.Math.Statistics as Stats
import QSTKUtil.Date
import Data.List.Split
import Data.List
import Data.Maybe
import qualified Data.Vector as V
import qualified Data.Map as Map
import Order
import Data.List.Utils
import Data.Time.Calendar

main =  do
        orders <- parseOrders
        let new_orders = map (uncur Order) orders
        let symbols = nub $ map sym new_orders
        let cash = 1000000
        dates <- DU.getNYSEdays (get_date (head new_orders)) (get_date (last new_orders))
        --let dates = map (get_date) new_orders
        let port = Map.fromList $ zip symbols [0,0..]
        p <- mapM (DP.readFrom (head dates) (last dates) 0 0) symbols
        let prices = Map.fromList p
        let daily = daily_port new_orders port dates
        let daily_cash = port_acc new_orders cash prices dates
        let equity_vals = map sum (map (equity_values prices) (zip daily [0..]))
        let port_value = zipWith (+) daily_cash equity_vals
        let returns = TSU.daily port_value
        print $ "Cash: " ++ (show $ zip dates port_value)
        print $ "Sharpe Ratio: " ++ (show $ TSU.getSharpeRatio returns)
        print $ "Total Returns: " ++ (show $ sum returns + 1)
        print $ "Standard Deviation: " ++ (show $ Stats.stddev returns)
        print $ "Average Daily Return: " ++ (show $ (sum returns) / (read (show $ length returns) :: Double))


equity_values :: Map.Map String [String] -> (Map.Map String Int, Int) -> [Double]
equity_values prices day_port = Map.elems $ Map.mapWithKey (calc prices (snd day_port)) (fst day_port)

calc :: Map.Map String [String] -> Int -> String -> Int -> Double
calc prices idx sym num_shares = (read ((fromMaybe ["0.0"] (Map.lookup sym prices)) !! idx) :: Double) * (read (show num_shares) :: Double)

daily_port :: [Order] -> Map.Map String Int -> [Day] -> [Map.Map String Int]
daily_port orders port dates = check_date orders port dates

check_date :: [Order] -> Map.Map String Int -> [Day] -> [Map.Map String Int]
check_date [] port [] = []
check_date orders port d =  if (get_date $ head orders) == (head d)
                            then [update_shares (head orders) port] ++ check_date (tail orders) (update_shares (head orders) port) (tail d)
                            else [port] ++ check_date orders port (tail d)

update_shares :: Order -> Map.Map String Int -> Map.Map String Int
update_shares order port
    | position order == "Buy" =  Map.insertWith (+) (sym order) (read (shares order) :: Int) port
    | otherwise = Map.insertWith (\new old -> old - new) (sym order) (read (shares order) :: Int) port

port_acc :: [Order] -> Double -> Map.Map String [String] -> [Day] -> [Double]
port_acc [] cash prices [] = []
port_acc orders cash prices dates = if (get_date $ head orders) == (head dates)
                                    then [(update_cash (head orders) cash prices)] ++ port_acc (tail orders) (update_cash (head orders) cash prices) (Map.map tail prices) (tail dates)
                                    else [cash] ++ port_acc orders cash (Map.map tail prices) (tail dates)


update_cash :: Order -> Double -> Map.Map String [String] -> Double
update_cash order cash prices
    | position order == "Buy" = cash - (read (shares order) :: Double) * (read (head (fromMaybe ["0"] (Map.lookup (sym order) prices))) :: Double)
    | otherwise               = cash + (read (shares order) :: Double) * (read (head (fromMaybe ["0"] (Map.lookup (sym order) prices))) :: Double)

uncur g [a, b, c, d, e, f] = g a b c d e f


parseOrders :: IO [[String]]
parseOrders =   do
                ordersFile <- readFile "orders.csv"
                let orders = map (splitOn ",") (lines ordersFile)
                return orders
