import sys
import csv
import QSTK.qstkutil.qsdateutil as du
import QSTK.qstkutil.tsutil as tsu
import QSTK.qstkutil.DataAccess as da

import numpy as np
import datetime as dt
import matplotlib.pyplot as plt
import pandas as pd

def main():
    if (len(sys.argv) == 4):
        order_book = list(read_csv(sys.argv[2]))

        s_date = dt.datetime(2011, 1, 10)
        e_date = dt.datetime(2011, 12, 20)

        symbols, data = setup(s_date, e_date, order_book)
        port = trade(sys.argv[1], order_book, symbols, data)

        #daily_rets = tsu.daily(port)
        #std_dev = np.std(daily_rets)
        #avg_daily = daily_rets / len(daily_rets)
        #sharpe = tsu.get_sharpe_ratio(port)
        #cum

    else:
        print("Please specify orders file and output file.")

def read_data(order_book, timestamps):
    data_obj = da.DataAccess('Yahoo')
    symbols = []
    for order in order_book:
        symbols.append(order['Sym'])
    symbols = list(set(symbols))
    keys = ['actual_close']
    all_data = data_obj.get_data(timestamps, symbols, keys)
    return symbols, dict(zip(keys, all_data))

def setup(s_date, e_date, order_book):
    time_of_day = dt.timedelta(hours=16)
    timestamps = du.getNYSEdays(s_date, e_date, time_of_day)
    symbols, data = read_data(order_book, timestamps)
    return symbols, data


def trade(cash, order_book, symbols, data):
    port = dict(zip(symbols, [0] * len(symbols)))
    timestamps = data['actual_close'].index
    for sym in symbols:
        for order in order_book:
            if order["Sym"].upper() == sym:
                if order["Type"] == "Buy":
                    port[sym] += int(order["Shares"])
                else:
                    port[sym] -= int(order["Shares"])
    print port


def read_csv(filename):
    return csv.DictReader(open(filename, 'rb'), delimiter=',', quotechar='"')

if __name__ == "__main__":
    main()
