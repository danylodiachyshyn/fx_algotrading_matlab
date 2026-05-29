function ATR = myATR(data, period, TF, FTSname, plotparam)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Help myATR  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computes Average True Range (ATR) for selected OHLC series.
%
% Inputs:
% data................numeric matrix (dates, open, high, low, close)
% period..............ATR lookback period (typically 14)
% TF..................time-frame label for plots
% FTSname.............instrument/time-series name
% plotparam...........if 1 -> draw plot
%
% Output:
% ATR.................ATR vector aligned with input rows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

High  = data(:, 3);
Low   = data(:, 4);
Close = data(:, 5);
[nRows, ~] = size(data);

% 1. Calculate True Range (TR)
TR = zeros(nRows, 1);
TR(1) = High(1) - Low(1); % First day has no previous close

for i = 2:nRows
    tr1 = High(i) - Low(i);
    tr2 = abs(High(i) - Close(i-1));
    tr3 = abs(Low(i) - Close(i-1));
    TR(i) = max([tr1, tr2, tr3]);
end

% 2. Calculate ATR (Wilder's Smoothing)
ATR = nan(nRows, 1);

if nRows > period
    % Initial ATR is a Simple Moving Average of the first 'period' TRs
    ATR(period) = sum(TR(1:period)) / period;

    % Subsequent ATRs use the smoothing formula from your slide
    for i = (period + 1):nRows
        ATR(i) = ((period - 1) * ATR(i-1) + TR(i)) / period;
    end
end

% 3. Plotting
if plotparam == 1
    f = figure;
    f.Position = [250 150 1600 400]; 
    plot(ATR, 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5);
    grid minor;
    xlabel(TF);
    ylabel('ATR Value');
    title([FTSname, ' : Average True Range (N=', num2str(period), ')']);
end
end