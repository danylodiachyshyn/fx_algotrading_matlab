function [ECAll, pFastOpt, pSlowOpt, pATROpt, thrOpt, SLOpt, TPOpt, ECOpt] = my_Sensitivity_Double_EMA_ATR_Strategy_SLTP(data, FTSname, TF, Currency, pFastRange, pSlowRange, pATRRange, thrRange, SLRange, TPRange, plotparam)
% ==================== Help =========================
% 6D Grid search maximizing final equity EC(end).
% ===================================================
ECAll = zeros(length(pFastRange), length(pSlowRange), length(pATRRange), length(thrRange), length(SLRange), length(TPRange));

for i1 = 1:length(pFastRange)
    for i2 = 1:length(pSlowRange)
        if pFastRange(i1) >= pSlowRange(i2); continue; end % Logical check: Fast < Slow
        for i3 = 1:length(pATRRange)
            for i4 = 1:length(thrRange)
                for i5 = 1:length(SLRange)
                    for i6 = 1:length(TPRange)
                        [~, ~, ~, ~, EC] = my_Double_EMA_ATR_Strategy_SLTP(data, [], [], [], pFastRange(i1), pSlowRange(i2), pATRRange(i3), thrRange(i4), SLRange(i5), TPRange(i6), 0);
                        if isempty(EC); ECAll(i1,i2,i3,i4,i5,i6) = 0; else; ECAll(i1,i2,i3,i4,i5,i6) = EC(end); end
                    end
                end
            end
        end
    end
    disp(["done with Fast EMA length = ", num2str(pFastRange(i1))])
end

[~, linearIndex] = max(ECAll(:));
[l1, l2, l3, l4, l5, l6] = ind2sub(size(ECAll), linearIndex);
pFastOpt = pFastRange(l1); 
pSlowOpt = pSlowRange(l2); 
pATROpt = pATRRange(l3);
thrOpt = thrRange(l4); 
SLOpt = SLRange(l5); 
TPOpt = TPRange(l6);

[~, ~, ~, ~, ECOpt] = my_Double_EMA_ATR_Strategy_SLTP(data, FTSname, TF, Currency, pFastOpt, pSlowOpt, pATROpt, thrOpt, SLOpt, TPOpt, 0);

if plotparam
    f = figure; f.Position = [100, 200, 1800, 900];
    plot(ECOpt, "g", "LineWidth", 1.5)
    xlabel(TF); ylabel(Currency); grid minor;
    txt = "Optimal EC -> Fast: " + pFastOpt + ", Slow: " + pSlowOpt + ", ATR: " + pATROpt + ...
        ", Thresh: " + thrOpt + ", SL: " + SLOpt + "%, TP: " + TPOpt + "%";
    title(txt)
end
end