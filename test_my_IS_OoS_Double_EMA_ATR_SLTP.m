% test_my_IS_OoS_Double_EMA_ATR_SLTP
clear, clc, close all

adress = '/MATLAB Drive/Main/Data/';
FTSname = 'EURUSD_H4.mat'; % Assumes you already converted your CSV to a .mat file
data = load([adress, FTSname]); data = data.data(:,1:5); 
FTSname2 = 'FX EURUSD H4 Out-of-Sample Test'; TF = 'H4'; Currency = '$';


% Dynamic 70/30 Split
n = round(length(data) * 0.70);  

% 1. Faster EMAs for more frequent crossover signals
%periodFastRange   = 3:2:9;        % Tighter tracking
%periodSlowRange   = 15:5:35;      % Faster trend baseline
%periodATRRange    = 10:2:14; 
% 2. Lower Volatility Bouncer (Allows trading in quieter markets)
%atrThresholdRange = 0.002:0.001:0.005; % 20 to 50 pips  
% 3. Tighter Risk Targets (Closes trades faster to free up the system)
%SLRange = 0.2:0.1:0.6;   % Stops out quickly on bad trades  
%TPRange = 0.4:0.2:1.2;   % Takes profit quickly (still maintains 1:2 ratio)#


% 1. Smoothed EMAs (Avoids intraday noise/whipsaws)
% Maps roughly to 1.5-day to 3-day fast trends, and 1-week to 2-week slow baselines
periodFastRange   = 8:4:20;       
periodSlowRange   = 40:10:80;      
periodATRRange    = 10:2:14;       % Standard lookback is still fine

% 2. Micro-Volatility Bouncer (H4 candles are much smaller than Daily)
% 0.0005 = 5 pips | 0.0020 = 20 pips
atrThresholdRange = 0.0005:0.0005:0.0020; 

% 3. Intraday/Intra-week Risk Targets
SLRange = 0.1:0.1:0.4;   % Tight stops (10 to 40 pips)
TPRange = 0.2:0.2:0.8;   % Realistic H4 targets (20 to 80 pips)



% 1. Macro Daily EMAs (Catches massive multi-month Bank of Japan trends)
%periodFastRange   = 10:2:20;       
%periodSlowRange   = 40:10:100;     
%periodATRRange    = 14;      

% 2. 🚨 THE JPY DECIMAL SHIFT (Scaled for Daily Volatility) 🚨
% A normal daily candle on USD/JPY moves 80 to 140 pips.
% 0.40 = 40 pips | 1.20 = 120 pips
%atrThresholdRange = 0.40:0.20:1.20; % Shifted slightly up to block daily noise

% 3. Long-Term Trend Risk Metrics
% Gives trades weeks to develop, aiming for massive home-run trades.
%SLRange = 0.5:0.5:2.0;   % Stop Loss: Roughly 75 to 300 pips
%TPRange = 1.5:0.5:5.0;   % Take Profit: Roughly 225 to 750 pips


% --- USD/JPY SPECIFIC OPTIMIZATION RANGES ---

% 1. Slower "Macro" EMAs (USD/JPY trends hard, don't get faked out early)
%periodFastRange   = 10:2:20;       
%periodSlowRange   = 40:10:100;     
%periodATRRange    = 14;      

% 2. 🚨 THE JPY DECIMAL SHIFT (CRITICAL) 🚨
% Because USD/JPY is priced in the 100s (e.g., 150.50), we must use whole decimals.
% 0.20 = 20 pips | 0.80 = 80 pips
%atrThresholdRange = 0.20:0.20:1.00; 

% 3. Trend-Following Risk Metrics
% Give the Yen room to breathe during BOJ interventions, and aim for huge targets.
%SLRange = 0.5:0.5:2.0;   % Wide stops
%TPRange = 1.5:0.5:5.0;   % Massive profit targets (1:2 to 1:3 ratios)




[EC_IS, optParams, EC_OoS] = my_IS_OoS_Double_EMA_ATR_Strategy_SLTP(...
    data, FTSname2, TF, Currency, periodFastRange, periodSlowRange, periodATRRange, ...
    atrThresholdRange, SLRange, TPRange, 1, n);

