% test_MC_DoubleEMA_ATR
clear, clc, close all
% --- Data Loading ---
% Update 'adress' to point to your exact folder path
adress = '/MATLAB Drive/Main/Data/';
FTSname = 'EURUSD_Daily.mat'; % Assumes you already converted your CSV to a .mat file
data = load([adress, FTSname]); data = data.data(:,1:5);
FTSname2 = 'FX EURUSD Daily Monte Carlo Test'; TF = 'Daily'; Currency = '$';

% --- IS/OoS Split (70/30) ---
n = round(length(data) * 0.80); 
dataIS  = data(1:n, :);
dataOoS = data(n+1:end, :);


% 1. Faster EMAs for more frequent crossover signals
periodFastRange   = 3:2:9;        % Tighter tracking
periodSlowRange   = 15:5:35;      % Faster trend baseline
periodATRRange    = 10:2:14; 
% 2. Lower Volatility Bouncer (Allows trading in quieter markets)
atrThresholdRange = 0.002:0.001:0.005; % 20 to 50 pips  
% 3. Tighter Risk Targets (Closes trades faster to free up the system)
SLRange = 0.2:0.1:0.6;   % Stops out quickly on bad trades  
TPRange = 0.4:0.2:1.2;   % Takes profit quickly (still maintains 1:2 ratio)#


% 1. Smoothed EMAs (Avoids intraday noise/whipsaws)
% Maps roughly to 1.5-day to 3-day fast trends, and 1-week to 2-week slow baselines
%periodFastRange   = 8:4:20;       
%periodSlowRange   = 40:10:80;      
%periodATRRange    = 10:2:14;       % Standard lookback is still fine

% 2. Micro-Volatility Bouncer (H4 candles are much smaller than Daily)
% 0.0005 = 5 pips | 0.0020 = 20 pips
%atrThresholdRange = 0.0005:0.0005:0.0020; 

% 3. Intraday/Intra-week Risk Targets
%SLRange = 0.1:0.1:0.4;   % Tight stops (10 to 40 pips)
%TPRange = 0.2:0.2:0.8;   % Realistic H4 targets (20 to 80 pips)



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





% --- Monte Carlo Parameters ---
nFutTrades = 500;    
nSim       = 2000;   
TradeFut   = 15;     % Evaluates health after 15 real trades to avoid intraday noise traps
QUmin      = 0.05;   % Strict 5% lower threshold
QUmax      = 0.95;   
plotparam  = 1;

% --- Run Simulation ---
disp('Starting Optimized Monte Carlo Engine...');
% UPDATED TO MATCH THE NEW FUNCTION NAME AND OUTPUTS
[tradesAllOoS, pFastOpt, pSlowOpt, pATROpt, thrOpt, SLOpt, TPOpt] = my_MonteCarlo_Double_EMA_ATR_Analysis(...
    dataIS, dataOoS, FTSname2, TF, Currency, ...
    periodFastRange, periodSlowRange, periodATRRange, atrThresholdRange, ...
    SLRange, TPRange, nFutTrades, nSim, TradeFut, QUmin, QUmax, plotparam);
disp('==================================================');
disp('✅ Simulation Complete!');
disp('--- WINNING PARAMETERS FOUND ---');
disp(['Fast EMA Period : ', num2str(pFastOpt)]);
disp(['Slow EMA Period : ', num2str(pSlowOpt)]);
disp(['ATR Period      : ', num2str(pATROpt)]);
disp(['ATR Threshold   : ', num2str(thrOpt)]);
disp(['Stop Loss       : ', num2str(SLOpt), '%']);
disp(['Take Profit     : ', num2str(TPOpt), '%']);
disp('==================================================');



% ==================================================
% --- REQUIRED ACADEMIC OUTPUTS (SEITE 8: MC DISTRIBUTIONS) ---
% ==================================================
disp('Calculating Monte Carlo Distributions (Max DD, Consecutive Losses)...');

% Assuming tradesAllOoS is a vector of your optimal trade returns (P&L)
trade_returns = tradesAllOoS; 

% Variables to store the end results of the 2000 simulations
sim_EndEC = zeros(nSim, 1);
sim_MaxDD = zeros(nSim, 1);
sim_MaxConsLoss = zeros(nSim, 1);

for i = 1:nSim
    % 1. Randomly sample trades with replacement (Monte Carlo Shuffle)
    random_indices = randi(length(trade_returns), nFutTrades, 1);
    simulated_trades = trade_returns(random_indices);

    % 2. Calculate Equity Curve
    sim_EC = cumsum(simulated_trades);
    sim_EndEC(i) = sim_EC(end); % Final Equity at T = numFutTrades

    % 3. Calculate Max Drawdown for this specific simulation
    running_max = cummax(sim_EC);
    drawdowns = running_max - sim_EC;
    sim_MaxDD(i) = max(drawdowns);

    % 4. Calculate Max Consecutive Negative Trades
    is_loss = simulated_trades < 0;
    streak = 0;
    max_streak = 0;
    for j = 1:length(is_loss)
        if is_loss(j) == 1
            streak = streak + 1;
            if streak > max_streak
                max_streak = streak;
            end
        else
            streak = 0;
        end
    end
    sim_MaxConsLoss(i) = max_streak;
end

% --- Calculate Percentiles (5% and 95%) ---
pct_EC = prctile(sim_EndEC, [5, 95]);
pct_MaxDD = prctile(sim_MaxDD, [5, 95]);
pct_MaxConsLoss = prctile(sim_MaxConsLoss, [5, 95]);

% --- Display Formatting for the Professor ---
disp('==================================================');
disp('📊 MONTE CARLO DISTRIBUTION RESULTS (2000 Simulations)');
disp(['Target Future Trades (T) : ', num2str(nFutTrades)]);
disp('--------------------------------------------------');
disp(['End EC (5% - 95%)    : ', num2str(pct_EC(1), '%.2f'), ' to ', num2str(pct_EC(2), '%.2f')]);
disp(['Max Drawdown (5% - 95%)        : ', num2str(pct_MaxDD(1), '%.2f'), ' to ', num2str(pct_MaxDD(2), '%.2f')]);
disp(['Max Consecutive Losses (5%-95%): ', num2str(pct_MaxConsLoss(1), '%.0f'), ' to ', num2str(pct_MaxConsLoss(2), '%.0f')]);
disp('==================================================');
