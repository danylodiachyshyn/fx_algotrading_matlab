function [tradesAllOoS, pFastOpt, pSlowOpt, pATROpt, thrOpt, SlOpt, TPOpt] = my_MonteCarlo_Double_EMA_ATR_Analysis(dataIS, dataOoS, FTSname, TF, Currency, pFastRange, pSlowRange, pATRRange, thrRange, SLRange, TPRange, nFutTrades, nSim, TradeFut, QUmin, QUmax, plotparam)

tf1 = TradeFut;
[~, pFastOpt, pSlowOpt, pATROpt, thrOpt, SlOpt, TPOpt, ~] = my_Sensitivity_Double_EMA_ATR_Strategy_SLTP(dataIS, FTSname, TF, Currency, pFastRange, pSlowRange, pATRRange, thrRange, SLRange, TPRange, 0);

% Generate trades using optimal parameters
[~, ~, ~, tradesAllIS, ~] = my_Double_EMA_ATR_Strategy_SLTP(dataIS, FTSname, TF, Currency, pFastOpt, pSlowOpt, pATROpt, thrOpt, SlOpt, TPOpt, 0);

% Monte Carlo Simulations Setup
tradesAllIS = tradesAllIS(tradesAllIS ~= 0);
ECclean = cumsum([0;tradesAllIS]);
rr = emprand(tradesAllIS, nFutTrades, nSim);
Traj = cumsum([ECclean(end)*ones(1,nSim);rr]);
MeanTraj = mean(Traj, 2);
QUminTRaj = quantile(Traj', QUmin);
QUmaxTRaj = quantile(Traj', QUmax);

% Check OoS condition
[~, ~, ~, tradesAllOoS, ~] = my_Double_EMA_ATR_Strategy_SLTP(dataOoS, FTSname, TF, Currency, pFastOpt, pSlowOpt, pATROpt, thrOpt, SlOpt, TPOpt, 0);
tradesAllOoS = tradesAllOoS(tradesAllOoS ~= 0);
TrajReal = cumsum([ECclean(end); tradesAllOoS]);

% --- System Invalidation (Kill Switch) Check ---
cond1 = length(TrajReal) >= TradeFut + 1;
if cond1
    % Strategy took enough trades to evaluate
    cond2 = sum(TrajReal(1:TradeFut + 1) - QUminTRaj(1:TradeFut + 1)' < 0) > 0;
    if cond2
        tradesAllOoS = tradesAllOoS(1:TradeFut); % Kill Switch Activated
    else
        TradeFut = length(tradesAllOoS) - 1; % Passed, plot everything
    end
else
    % BUG FIX: Strategy took FEWER trades than the evaluation window.
    % We shrink the plotting window to match the actual trades taken to prevent a crash.
    disp(['Note: Only ', num2str(length(tradesAllOoS)), ' trades executed in OoS (Fewer than TradeFut).']);
    TradeFut = length(tradesAllOoS) - 1;
end

% --- Plot Equity Trajectories ---
if plotparam == 1
    aa = min(min(Traj));
    figure; hold on; grid minor;
    plot(ECclean, 'g','LineWidth', 2)
    plot(length(ECclean):length(ECclean) + nFutTrades, Traj, 'Color', [0.8 0.8 0.8 0.3])
    plot(length(ECclean):length(ECclean) + nFutTrades, MeanTraj, 'c', 'LineWidth',1.5)
    plot(length(ECclean):length(ECclean) + nFutTrades, QUminTRaj, 'c--', 'LineWidth',1.5)
    plot(length(ECclean):length(ECclean) + nFutTrades, QUmaxTRaj, 'c--', 'LineWidth',1.5)

    % Now safely plots the correct amount of trades without crashing
    plot(length(ECclean):length(ECclean) + TradeFut, TrajReal(1:TradeFut +1), 'b', 'LineWidth', 2)

    xline(length(ECclean) + tf1 , 'k--')
    text(length(ECclean) + tf1 + 2, aa, ['Decision after ', num2str(tf1), ' Trades'])
    xlabel('Number of Trades'); ylabel(Currency);
    title([FTSname, ': EC IS and OoS with MC Simulation, Double EMA + ATR']);
    hold off;
end
end