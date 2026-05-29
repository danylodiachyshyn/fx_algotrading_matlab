function [ECOoS, Results] = my_ForwardLookingAnalysisDoubleEMA_ATR(data, FTSname, TF, Currency, pFastRange, pSlowRange, pATRRange, thrRange, SLRange, TPRange, length1, factorIS, factorOoS, plotparam)

lengthIS = round(length1 * factorIS);
lengthOoS = round(length1 * factorOoS);
lengthAll = lengthIS + lengthOoS;
lengthOfData = size(data, 1);
k = 1;

while lengthAll < lengthOfData
    lengthAll = lengthAll + lengthOoS;
    k = k + 1;
end
ind = zeros(k, 4);
ind(1, :) = [1, lengthIS, lengthIS + 1, lengthIS + lengthOoS];
i = 1;
while i < k
    ind(i + 1, :) = ind(i, :) + lengthOoS;
    i = i + 1;
end
ind(end, end) = lengthOfData;

if size(ind, 1) >= 2 && ind(end, end) - ind(end-1, end) <= max([pSlowRange(end), pATRRange(end)])
    aa = ind(end, end);
    ind(end, :) = [];
    ind(end, end) = aa;
end

Results = cell(size(ind, 1), 7);
for hh = 1:size(ind, 1)
    dataIS = data(ind(hh, 1):ind(hh, 2), :);
    [~, pFastOpt, pSlowOpt, pATROpt, thrOpt, SLOpt, TPOpt, ~] = my_Sensitivity_Double_EMA_ATR_Strategy_SLTP(dataIS, FTSname, TF, Currency, pFastRange, pSlowRange, pATRRange, thrRange, SLRange, TPRange, 0);
    
    dataOoS = data(ind(hh, 3):ind(hh, 4), :);
    [~, ~, ~, TradesAll, ~] = my_Double_EMA_ATR_Strategy_SLTP(dataOoS, FTSname, TF, Currency, pFastOpt, pSlowOpt, pATROpt, thrOpt, SLOpt, TPOpt, 0);
    
    Results{hh,1} = pFastOpt; Results{hh,2} = pSlowOpt; Results{hh,3} = pATROpt;
    Results{hh,4} = thrOpt; Results{hh,5} = SLOpt; Results{hh,6} = TPOpt;
    Results{hh,7} = TradesAll;
end

lengthOfResults = zeros(size(ind, 1), 1);
for i = 1:size(Results, 1)
    lengthOfResults(i) = length(Results{i, 7});
end
indices = zeros(size(Results, 1), 2);
indices(1,1) = 1; indices(1,2) = lengthOfResults(1);
TradesOoS(1:lengthOfResults(1)) = Results{1,7};
i = 2;
while i <= size(Results, 1)
    indices(i, 1) = indices(i - 1, 2) + 1;
    indices(i, 2) = indices(i - 1, 2) + lengthOfResults(i);
    TradesOoS(indices(i, 1):indices(i, 2)) = Results{i, 7};
    i = i + 1;
end

ECOoS = cumsum([0; TradesOoS']);

Results = cell2table(Results, 'VariableNames', {'FastEMA', 'SlowEMA', 'ATRPer', 'ATRThresh', 'StopLoss (%)', 'Take Profit (%)', 'Trades P&L'});
StartIS = table(ind(:, 1), 'VariableNames', {'Start IS'});
EndIS = table(ind(:, 2), 'VariableNames', {'End IS'});
StartOoS = table(ind(:, 3), 'VariableNames', {'Start OoS'});
EndOoS = table(ind(:, 4), 'VariableNames', {'End OoS'});
Results = [Results, StartIS, EndIS, StartOoS, EndOoS];

if plotparam == 1
    f = figure; f.Position = [150 150 2000 950];
    subplot(1,2,1); plot(data(ind(1,3):end, 5), 'b');
    xlabel(TF); ylabel(Currency); title([FTSname, ' : Closing Price']); grid minor;
    
    subplot(1,2,2); plot(ECOoS, 'g', 'LineWidth', 1.5);
    xlabel(TF); ylabel(Currency); title('Walk-Forward Analysis : Equity Curve'); grid minor;
end
end