import sys
import csv
import QSTK.qstkutil.qsdateutil as du
import QSTK.qstkutil.tsutil as tsu
import QSTK.qstkutil.DataAccess as da

from itertools import *
import numpy as np
import datetime as dt
import matplotlib.pyplot as plt
import pandas as pd

def main():
    if (len(sys.argv) == 3):
        order_book = list(read_csv(sys.argv[2]))

        s_date = dt.datetime(2011, 1, 10)
        e_date = dt.datetime(2011, 12, 21)

        symbols, data = setup(s_date, e_date, order_book)
        dates, port = trade(float(sys.argv[1]), order_book, symbols, data)
        returns = tsu.returnize0(port)

        spx_data = [{'Sym': '$SPX'}]
        symbols, data = setup(s_date, e_date, spx_data)
        spx_returns = tsu.returnize0(data['close']['$SPX'].values)

        sharpe = tsu.get_sharpe_ratio(returns)[0]
        spx_sharpe = tsu.get_sharpe_ratio(spx_returns)[0]
        std_dev = np.std(returns)
        spx_std_dev = np.std(spx_returns)
        avg_daily = returns / len(returns)
        spx_avg_daily = spx_returns / len(spx_returns)

        print "Sharpe Ratio: " + str(sharpe)
        print "SPX Sharpe Ratio: " + str(spx_sharpe)
        print "\nTotal Return: " + str(float(sum(returns) + 1))
        print "SPX Total Return: " + str(float(sum(spx_returns) + 1))
        print "\nStandard Deviation: " + str(std_dev)
        print "SPX Standard Deviation: " + str(spx_std_dev)
        print "\nAverage Daily Return: " + str(float(sum(avg_daily)))
        print "SPX Average Daily Return: " + str(float(sum(spx_avg_daily)))

        create_plot(dates, returns, spx_returns)

    else:
        print("Please specify orders file and output file.")

def create_plot(dates, port_returns, spx_returns):
    plt.clf()
    port_returns = list(chain.from_iterable(port_returns))
    spx_returns = list(chain.from_iterable(spx_returns))
    values = zip(port_returns, spx_returns)
    plt.plot(dates, values)
    plt.ylabel("Portfolio Value")
    plt.xlabel("Dates")
    plt.legend(["Portfolio", "SPX"])
    plt.savefig("figure.pdf", format="pdf")


def read_data(order_book, timestamps):
    data_obj = da.DataAccess('Yahoo')
    symbols = []
    for order in order_book:
        symbols.append(order['Sym'])
    symbols = list(set(symbols))
    keys = ['close']
    all_data = data_obj.get_data(timestamps, symbols, keys)
    return symbols, dict(zip(keys, all_data))

def setup(s_date, e_date, order_book):
    time_of_day = dt.timedelta(hours=16)
    timestamps = du.getNYSEdays(s_date, e_date, time_of_day)
    symbols, data = read_data(order_book, timestamps)
    return symbols, data


def trade(cash, order_book, symbols, data):
    port = dict(zip(symbols, [0] * len(symbols)))
    symbols.append('CASH')
    cash_dict = dict(zip(symbols, [0] * len(symbols)))
    cash_dict['CASH'] = cash
    timestamps = data['close'].index
    dates = []
    port_values = []
    for timestamp in timestamps:
        for order in order_book:
            date = dt.datetime(int(order["Year"]), int(order["Month"]), int(order["Day"])) + dt.timedelta(hours=16)
            if (date == timestamp):
                cash_dict = execute(order["Sym"], data, timestamp, order, cash_dict, port)
            cash_dict[order["Sym"]] = int(port[order["Sym"]]) * data['close'][order["Sym"]][timestamp]
        cash = sum(cash_dict.values())
        dates.append(",".join(str(timestamp)[:10].split('-')))
        port_values.append(cash)
    return timestamps, port_values

def get_cash(sym, data, timestamp, port):
    cash_value = port[sym] * data['close'][sym][timestamp]
    return cash_value

def execute(sym, data, timestamp, order, cash_dict, port):
    if order["Sym"].upper() == sym:
        if order["Type"] == "Buy":
            cash_dict['CASH'] -= int(order["Shares"]) * data['close'][sym][timestamp]
            port[sym] += int(order["Shares"])
            cash_dict[sym] = int(order["Shares"]) * data['close'][sym][timestamp]
        if order["Type"] == "Sell":
            cash_dict['CASH'] += int(order["Shares"]) * data['close'][sym][timestamp]
            port[sym] -= int(order["Shares"])
            cash_dict[sym] = int(order["Shares"]) * data['close'][sym][timestamp]
    return cash_dict

def read_csv(filename):
    return csv.DictReader(open(filename, 'rb'), delimiter=',', quotechar='"')

if __name__ == "__main__":
    main()
