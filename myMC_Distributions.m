function MCStats = myMC_Distributions(tradesIS, nFutTrades, nSim, QUmin, QUmax, Currency, plotparam)
%%%%%%%%%%%%%%%%%%% Help myMC_Distributions %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Monte Carlo Distribution Analysis at T = nFutTrades.
% Computes distributions and percentiles for:
%   1. Final EC (equity at end of simulated trades)
%   2. Max Drawdown
%   3. Max Consecutive Negative Trades
%
% Inputs:
%   tradesIS........vector of IS trade P&Ls (zeros removed)
%   nFutTrades......number of future trades to simulate
%   nSim............number of MC simulations
%   QUmin, QUmax....quantile bounds (e.g., 0.05, 0.95)
%   Currency........string for display
%   plotparam.......if 1 -> draw distribution plots
%
% Output:
%   MCStats.........struct with distributions and percentiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Generate MC Simulations
rr = emprand(tradesIS, nFutTrades, nSim);

% 2. Compute metrics for each simulation
finalEC     = zeros(nSim, 1);
maxDD       = zeros(nSim, 1);
maxConsecL  = zeros(nSim, 1);

for s = 1:nSim
    simTrades = rr(:, s);
    simEC = cumsum(simTrades);
    
    % Final EC
    finalEC(s) = simEC(end);
    
    % Max Drawdown
    peakEC = cummax(simEC);
    dd = simEC - peakEC;
    maxDD(s) = min(dd);
    
    % Max Consecutive Negative Trades
    maxConsecL(s) = calcMaxConsecNeg(simTrades);
end

% 3. Percentiles
pctiles = [0.01, 0.05, 0.10, 0.25, 0.50, 0.75, 0.90, 0.95, 0.99];

MCStats.FinalEC.values      = finalEC;
MCStats.FinalEC.mean        = mean(finalEC);
MCStats.FinalEC.percentiles = quantile(finalEC, pctiles);

MCStats.MaxDD.values        = maxDD;
MCStats.MaxDD.mean          = mean(maxDD);
MCStats.MaxDD.percentiles   = quantile(maxDD, pctiles);

MCStats.MaxConsecLoss.values      = maxConsecL;
MCStats.MaxConsecLoss.mean        = mean(maxConsecL);
MCStats.MaxConsecLoss.percentiles = quantile(maxConsecL, pctiles);

MCStats.Percentiles = pctiles;

% 4. Display
disp('==========================================================');
disp(['  MC DISTRIBUTIONS AT T = ', num2str(nFutTrades), ' TRADES (', num2str(nSim), ' simulations)']);
disp('==========================================================');
disp(' ');
disp('--- Final Equity Curve ---');
disp(['  Mean: ', num2str(MCStats.FinalEC.mean, '%.4f'), ' ', Currency]);
disp(['  5th Percentile:  ', num2str(MCStats.FinalEC.percentiles(2), '%.4f')]);
disp(['  50th Percentile: ', num2str(MCStats.FinalEC.percentiles(5), '%.4f')]);
disp(['  95th Percentile: ', num2str(MCStats.FinalEC.percentiles(8), '%.4f')]);
disp(' ');
disp('--- Max Drawdown ---');
disp(['  Mean: ', num2str(MCStats.MaxDD.mean, '%.4f'), ' ', Currency]);
disp(['  5th Percentile (worst):  ', num2str(MCStats.MaxDD.percentiles(2), '%.4f')]);
disp(['  50th Percentile:         ', num2str(MCStats.MaxDD.percentiles(5), '%.4f')]);
disp(['  95th Percentile (best):  ', num2str(MCStats.MaxDD.percentiles(8), '%.4f')]);
disp(' ');
disp('--- Max Consecutive Losses ---');
disp(['  Mean: ', num2str(MCStats.MaxConsecLoss.mean, '%.1f'), ' trades']);
disp(['  5th Percentile (best):  ', num2str(MCStats.MaxConsecLoss.percentiles(2), '%.0f')]);
disp(['  50th Percentile:        ', num2str(MCStats.MaxConsecLoss.percentiles(5), '%.0f')]);
disp(['  95th Percentile (worst):', num2str(MCStats.MaxConsecLoss.percentiles(8), '%.0f')]);
disp('==========================================================');

% 5. Plotting
if plotparam == 1
    f = figure;
    f.Position = [100 100 1800 500];
    
    % Final EC Distribution
    subplot(1,3,1)
    histogram(finalEC, 50, 'FaceColor', [0.2 0.7 0.3], 'EdgeAlpha', 0.3);
    hold on;
    xline(quantile(finalEC, QUmin), 'r--', ['Q', num2str(QUmin*100), '%'], 'LineWidth', 1.5);
    xline(quantile(finalEC, QUmax), 'b--', ['Q', num2str(QUmax*100), '%'], 'LineWidth', 1.5);
    xline(mean(finalEC), 'k-', 'Mean', 'LineWidth', 1.5);
    hold off; grid minor;
    xlabel(Currency); ylabel('Frequency');
    title(['Final EC Distribution (T=', num2str(nFutTrades), ')']);
    
    % Max Drawdown Distribution
    subplot(1,3,2)
    histogram(maxDD, 50, 'FaceColor', [0.9 0.2 0.2], 'EdgeAlpha', 0.3);
    hold on;
    xline(quantile(maxDD, QUmin), 'r--', ['Q', num2str(QUmin*100), '% (worst)'], 'LineWidth', 1.5);
    xline(mean(maxDD), 'k-', 'Mean', 'LineWidth', 1.5);
    hold off; grid minor;
    xlabel(Currency); ylabel('Frequency');
    title('Max Drawdown Distribution');
    
    % Max Consecutive Losses Distribution
    subplot(1,3,3)
    histogram(maxConsecL, 'BinMethod', 'integers', 'FaceColor', [0.9 0.6 0.1], 'EdgeAlpha', 0.3);
    hold on;
    xline(quantile(maxConsecL, QUmax), 'r--', ['Q', num2str(QUmax*100), '% (worst)'], 'LineWidth', 1.5);
    xline(mean(maxConsecL), 'k-', 'Mean', 'LineWidth', 1.5);
    hold off; grid minor;
    xlabel('Consecutive Losses'); ylabel('Frequency');
    title('Max Consecutive Losses Distribution');
end
end

% --- Helper ---
function n = calcMaxConsecNeg(trades)
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