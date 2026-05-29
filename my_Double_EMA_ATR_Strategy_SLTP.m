function [EMAFast, EMASlow, ATR, tradesAll, EC] = my_Double_EMA_ATR_Strategy_SLTP(data, FTSname, TF, Currency, periodFast, periodSlow, periodATR, atrThreshold, SL, TP, plotparam)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Help %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Double EMA Crossover + ATR Volatility Filter + SL/TP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Call External Helper Functions (Calculate Indicators)
EMAFast = myEMA(data, periodFast, "C", TF, FTSname, Currency, 0);
EMASlow = myEMA(data, periodSlow, "C", TF, FTSname, Currency, 0);
ATR = myATR(data, periodATR, TF, FTSname, 0);

% 2. Clean up Burn-In periods (Aligns array sizes and removes NaNs)
maxPeriod = max([periodFast, periodSlow, periodATR]);
EMAFast(1:maxPeriod - 1) = [];
EMASlow(1:maxPeriod - 1) = [];
ATR(1:maxPeriod - 1) = [];
data(1:maxPeriod - 1, :) = [];

O = data(:,2);
C = data(:,5);
SL = SL/100;
TP = TP/100;

% 3. Calculate the Position Vector
position = zeros(length(EMAFast), 1);
if EMAFast(1) >= EMASlow(1); position(1) = 1; else; position(1) = -1; end

for i = 2:length(position)
    if EMAFast(i) > EMASlow(i) && ATR(i) > atrThreshold
        position(i) = 1;
    elseif EMAFast(i) < EMASlow(i) && ATR(i) > atrThreshold
        position(i) = -1;
    else
        position(i) = position(i-1); % Hold previous position if ATR is too low
    end
end

% 4. Define and calculate the P&L of each Trade
l1 = length(position);
tradesAll = zeros(l1, 1);
tradeOpen = O(1); 
tradeInd = 1; 

if position(end-1) == position(end)
    l1 = length(position);
else
    jj = length(position);
    while position(jj) ~= position(jj - 1)
        jj = jj - 1;
    end
    l1 = jj;
end

for ii = 2:l1
    % ===============================================================
    % We flipped to -1 (SHORT). That means the LONG trade ended. 
    % We correctly apply the LONG math here.
    % ===============================================================
    if position(ii-1) == 1 && position(ii) == -1 
        dataTrade = data(tradeInd:ii,:);
        Trade = 0; index = 1; LT = size(dataTrade,1);
        tradeSL = tradeOpen*(1 - SL); tradeTP = tradeOpen*(1 + TP); % LONG Math
        
        while index <= LT
            tmpOpen = dataTrade(index,2); tmpHigh = dataTrade(index,3); tmpLow = dataTrade(index,4);
            if tmpOpen <= tradeSL
               Trade = tmpOpen - tradeOpen; break;
            elseif tmpOpen >= tradeTP
                Trade = tmpOpen - tradeOpen; break;
            elseif and(tmpLow > tradeSL, tmpHigh >= tradeTP)
                Trade = tradeOpen*TP; break;
            elseif and(tmpLow <= tradeSL, tmpHigh < tradeTP)
                Trade = -tradeOpen*SL; break;
            elseif and(Trade == 0, index == LT)
                Trade = O(min(ii + 1, length(O))) - tradeOpen; break;
            end
            index = index + 1;
        end
        if ii < l1
            tradeOpen = O(ii+1); tradeInd = ii + 1;
        end
        
    % ===============================================================
    % We flipped to 1 (LONG). That means the SHORT trade ended. 
    % We correctly apply the SHORT math here.
    % ===============================================================
    elseif position(ii-1) == -1 && position(ii) == 1 
        dataTrade = data(tradeInd : ii, 2 : 5);
        Trade = 0; index = 1 ; LT = size(dataTrade,1);
        tradeTP = tradeOpen*(1 - TP); tradeSL = tradeOpen*(1 + SL); % SHORT Math       
        
        while index <= LT
            tmpOpen = dataTrade(index, 1); tmpHigh = dataTrade(index, 2); tmpLow = dataTrade(index, 3);
            if tmpOpen >= tradeSL 
                Trade = tradeOpen-tmpOpen; break;     
            elseif tmpOpen <= tradeTP 
                Trade = tradeOpen-tmpOpen ; break;            
            elseif and(tmpLow > tradeTP, tmpHigh >= tradeSL)
                Trade = -SL*tradeOpen; break;            
            elseif and(tmpLow <= tradeTP, tmpHigh < tradeSL)
                Trade = TP*tradeOpen; break;                 
            elseif and(index == LT , Trade == 0)
                Trade = tradeOpen - O(min(ii+1, length(O)));
            end
            index = index +1;
        end
        if ii < length(position)
            tradeOpen = O(ii + 1); tradeInd = ii + 1;
        end
    else
        Trade = 0;
    end
    
    if ii < length(position)
        tradesAll(ii +1) = Trade;
    end
end

% 5. Calculate the Equity Curve
EC = cumsum(tradesAll);

% 6. Plotting
if plotparam == 1
    % Increased figure height slightly to comfortably fit 3 panels
    f = figure; f.Position = [100, 100 2200 1100]; 
    
    % Top Panel: Price & EMAs
    ax1 = subplot(3,1,1);
    plot(C, 'b', 'LineWidth',1.2); hold on;
    plot(EMAFast, 'r--', 'LineWidth',1.2);
    plot(EMASlow, 'm--', 'LineWidth',1.2); hold off;
    title([FTSname,' : Close & Double EMA (Fast=',num2str(periodFast),', Slow=',num2str(periodSlow),')']);
    ylabel(Currency); grid minor;
    
    % Middle Panel: ATR & Volatility Threshold
    ax2 = subplot(3,1,2);
    plot(ATR, 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5); hold on;
    yline(atrThreshold, 'g--', ['Threshold: ', num2str(atrThreshold)], 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left'); hold off;
    title(['Average True Range (Period=', num2str(periodATR), ')']);
    ylabel('ATR'); grid minor;
    
    % Bottom Panel: Equity Curve
    ax3 = subplot(3,1,3);
    plot(EC, 'g', 'LineWidth',1.2);
    title([FTSname, ' : EC Double EMA, SL=', num2str(SL*100),'%, TP=', num2str(TP*100),'%']);
    xlabel(TF); ylabel(Currency); grid minor;
    
    % Link the X-axes of all three subplots so zooming in on one zooms them all
    linkaxes([ax1, ax2, ax3], 'x');
end
end