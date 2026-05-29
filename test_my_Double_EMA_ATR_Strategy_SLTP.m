% test_my_Double_EMA_ATR_Strategy_SLTP
clear, clc, close all

% --- Data Loading Setup ---
adress = '/MATLAB Drive/Main/Data/';
%FTSname = 'EURUSD_H4.mat';
FTSname = 'EURUSD_H4.mat';% Assumes you already converted your CSV to a .mat file
data = load([adress, FTSname]);
data = data.data;
data = data(:,1:5); 

FTSname2 = 'EURUSD H4';
TF = 'h4';
Currency = '$';

% --- Strategy Parameters ---
periodFast = 15;
periodSlow = 70;
periodATR  = 10;           % Standard ATR lookback

% Set the ATR Threshold! 
% Adjust this based on the actual price of the asset you are testing.
atrThreshold = 0.002;       

SL = 0.3;             
TP = 0.6;        
plotparam = 1;

% --- Execution ---
[EMAFast, EMASlow, ATR, tradesAll, EC] = my_Double_EMA_ATR_Strategy_SLTP(...
    data, FTSname2, TF, Currency, periodFast, periodSlow, periodATR, atrThreshold, SL, TP, plotparam);