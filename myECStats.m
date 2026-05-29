function Stats = myECStats(tradesAll, Currency, plotparam)
%%%%%%%%%%%%%%%%%%% Help myECStats %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computes and displays key statistics of an Equity Curve.
%
% Inputs:
%   tradesAll.......vector of trade P&Ls (zeros removed or included)
%   Currency........string for display (e.g., '€')
%   plotparam.......if 1 -> draw EC + Drawdown plot
%
% Output:
%   Stats...........struct with all computed metrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove zero entries (non-trade days)
trades = tradesAll(tradesAll ~= 0);
EC = cumsum([0; trades]);

% --- Core Metrics ---
Stats.PnL            = EC(end);
Stats.NumTrades      = length(trades);
Stats.WinningTrades  = sum(trades > 0);
Stats.LosingTrades   = sum(trades < 0);
Stats.WinRate        = Stats.WinningTrades / Stats.NumTrades * 100;
Stats.AvgWin         = mean(trades(trades > 0));
Stats.AvgLoss        = mean(trades(trades < 0));
Stats.ProfitFactor   = abs(sum(trades(trades > 0)) / sum(trades(trades < 0)));

% --- Max Drawdown ---
peakEC = cummax(EC);
DD = EC - peakEC;
Stats.MaxDrawDown    = min(DD);
[~, ddIdx]           = min(DD);
Stats.MaxDD_Index    = ddIdx;

% --- Max Consecutive Losses ---
Stats.MaxConsecLoss  = maxConsecNeg(trades);

% --- Max Consecutive Wins ---
Stats.MaxConsecWin   = maxConsecPos(trades);

% --- Display ---
disp('==========================================================');
disp(['        EQUITY CURVE STATISTICS (' Currency ')']);
disp('==========================================================');
disp(['Total P&L              : ', num2str(Stats.PnL, '%.4f'), ' ', Currency]);
disp(['Number of Trades       : ', num2str(Stats.NumTrades)]);
disp(['Winning Trades         : ', num2str(Stats.WinningTrades), ' (', num2str(Stats.WinRate, '%.1f'), '%)']);
disp(['Losing Trades          : ', num2str(Stats.LosingTrades)]);
disp(['Avg Win                : ', num2str(Stats.AvgWin, '%.4f'), ' ', Currency]);
disp(['Avg Loss               : ', num2str(Stats.AvgLoss, '%.4f'), ' ', Currency]);
disp(['Profit Factor          : ', num2str(Stats.ProfitFactor, '%.2f')]);
disp(['Max Drawdown           : ', num2str(Stats.MaxDrawDown, '%.4f'), ' ', Currency]);
disp(['Max Consecutive Losses : ', num2str(Stats.MaxConsecLoss)]);
disp(['Max Consecutive Wins   : ', num2str(Stats.MaxConsecWin)]);
disp('==========================================================');

% --- Plotting ---
if plotparam == 1
    f = figure;
    f.Position = [150 150 1600 700];

    subplot(2,1,1)
    plot(EC, 'g', 'LineWidth', 1.5); grid minor;
    xlabel('Trade #'); ylabel(Currency);
    title(['Equity Curve | P&L = ', num2str(Stats.PnL, '%.4f'), ' ', Currency]);

    subplot(2,1,2)
    area(DD, 'FaceColor', [1 0.2 0.2], 'FaceAlpha', 0.4, 'EdgeColor', 'r');
    grid minor; xlabel('Trade #'); ylabel(Currency);
    title(['Drawdown | Max DD = ', num2str(Stats.MaxDrawDown, '%.4f'), ' ', Currency]);
end
end

% --- Helper: max consecutive negative trades ---
function n = maxConsecNeg(trades)
    n = 0; count = 0;
    for i = 1:length(trades)
        if trades(i) < 0
            count = count + 1;
            if count > n; n = count; end
        else
            count = 0;
        end
    end
end

% --- Helper: max consecutive positive trades ---
function n = maxConsecPos(trades)
    n = 0; count = 0;
    for i = 1:length(trades)
        if trades(i) > 0
            count = count + 1;
            if count > n; n = count; end
        else
            count = 0;
        end
    end
end