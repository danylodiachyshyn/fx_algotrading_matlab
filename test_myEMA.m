% test_myEMA
clear, clc, close all
adress = '/MATLAB Drive/Main/Data/';
FTSname = 'USDJPY_H4.mat';

FTSname2 = 'FX EURUSD Walk-Forward Test'; 
Currency = '$';
data = load([adress, FTSname]);
data = data.data;
data(:, 6:end) = [];
period = 20;
OHLC = "C";
TF = 'Daily';
plotparam = 1;

EMA = myEMA(data, period, OHLC, TF, FTSname2, Currency, plotparam);
