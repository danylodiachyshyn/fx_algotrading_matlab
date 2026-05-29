function EMA = myEMA(data, period, OHLC, TF, FTSname, Currency, plotparam)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Help myEMA  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computes Exponential Moving Average (EMA) for selected OHLC series.
%
% Inputs:
% data................numeric matrix with 5 columns: date, open, high, low, close
% period..............EMA span length
% OHLC................"O", "H", "L", or "C" to select price series
% TF..................time-frame label for plots
% FTSname.............instrument/time-series name
% Currency............currency label for y-axis
% plotparam...........if 1 -> draw plot
%
% Output:
% EMA.................EMA vector aligned with input rows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if OHLC == "O"
    px = data(:, 2);
    pxLabel = 'Open Price';
elseif OHLC == "H"
    px = data(:, 3);
    pxLabel = 'High Price';
elseif OHLC == "L"
    px = data(:, 4);
    pxLabel = 'Low Price';
else
    px = data(:, 5);
    pxLabel = 'Closing Price';
end

[nRows, ~] = size(data);
EMA = nan(nRows, 1);
N = period;
alpha = 2 / (N + 1);

if nRows >= N
    EMA(N) = sum(px(1:N)) / N;
    for iRow = N + 1:nRows
        prevVal = EMA(iRow - 1);
        currPx = px(iRow);
        EMA(iRow) = (currPx - prevVal) * alpha + prevVal;
    end
end

if plotparam == 1
    f = figure;
    f.Position = [200 100 1600 900];
    plot(px(N:end), 'Color', [0.25 0.25 0.25], 'LineWidth', 1.0)
    hold on
    plot(EMA(N:end), 'Color', [0.00 0.75 0.95], 'LineWidth', 1.3)
    grid minor
    xlabel(TF)
    ylabel(Currency)
    title([FTSname, ' : ', pxLabel, ' and EMA of period N = ', num2str(N)])
    legend('Price', 'EMA', 'Location', 'best')
    hold off
end

