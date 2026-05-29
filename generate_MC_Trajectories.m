% generate_MC_Trajectories
tradesAll = tradesAll(tradesAll ~= 0);
nFutTrades = 300;
nSim = 1000;
figure
histogram(tradesAll, 30)
figure
ecdf(tradesAll)
xline(0,'k--')
ECclean = cumsum([0;tradesAll]);
rr = emprand(tradesAll, nFutTrades, nSim);
Traj = cumsum([ECclean(end)*ones(1,nSim);rr]);
Qumin = 0.05;
Qumax = 0.75;
QUminTRaj = quantile(Traj', Qumin);
QUmaxTRaj = quantile(Traj', Qumax);
MeanTraj = mean(Traj, 2);
hold on
ecdf(rr(:))
hold off

figure
plot(ECclean, 'g','LineWidth', 2)
hold on
grid minor
plot(length(ECclean):length(ECclean) + nFutTrades,Traj)
plot(length(ECclean):length(ECclean) + nFutTrades, MeanTraj, 'c', 'LineWidth',1.5)
plot(length(ECclean):length(ECclean) + nFutTrades, QUminTRaj, 'c--', 'LineWidth',1.5)
plot(length(ECclean):length(ECclean) + nFutTrades, QUmaxTRaj, 'c--', 'LineWidth',1.5)
hold off



