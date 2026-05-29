function [EC_IS, pFastOpt, pSlowOpt, pATROpt, thrOpt, SLOpt, TPOpt, EC_OoS] = my_IS_OoS_Double_EMA_ATR_Strategy_SLTP(data, FTSname, TF, Currency, pFastRange, pSlowRange, pATRRange, thrRange, SLRange, TPRange, plotparam, n)

% Prepare data IS and OoS
dataIS = data(1:n,:);
dataOoS = data(n+1:end,:);

% Calculate optimal parameters using IS Data
[~, pFastOpt, pSlowOpt, pATROpt, thrOpt, SLOpt, TPOpt, ~] = my_Sensitivity_Double_EMA_ATR_Strategy_SLTP(dataIS, FTSname, TF, Currency, pFastRange, pSlowRange, pATRRange, thrRange, SLRange, TPRange, 0);

% Calculate the optimal EC for IS Data
[~, ~, ~, ~, EC_IS] = my_Double_EMA_ATR_Strategy_SLTP(dataIS, FTSname, TF, Currency, pFastOpt, pSlowOpt, pATROpt, thrOpt, SLOpt, TPOpt, 0);

% Calculate the optimal EC for OoS Data
[~, ~, ~, ~, EC_OoS] = my_Double_EMA_ATR_Strategy_SLTP(dataOoS, FTSname, TF, Currency, pFastOpt, pSlowOpt, pATROpt, thrOpt, SLOpt, TPOpt, 0);

% Plot
if plotparam == 1
   f = figure; f.Position = [150 150 2000 950];
   subplot(1,2,1); plot(EC_IS, 'g', 'LineWidth', 1.5); grid minor;
   xlabel(TF); ylabel(Currency); title([FTSname,' : Optimal EC IS']);
   
   subplot(1,2,2); plot(EC_OoS, 'g', 'LineWidth', 1.5); grid minor;
   xlabel(TF); ylabel(Currency); title([FTSname,' : Optimal EC OoS']);
end
end