function residplot(m)
figure;
yh=yhat(m);
res=resid(m);
n=length(yh);
%simple residuals
subplot(3,1,1);
scatter(yh,res);
xlabel(['Predicted ' dep(m)]);
ylabel('Residual');
title('Test for heteroscedasticity');
subplot(3,1,2);
scatter(res(2:end),res(1:(end-1)));
xlabel('Resid_{i-1}');
ylabel('Resid_{i}');
title('Test for correlation of residuals');
subplot(3,1,3);
sortres=sort(res);
pctl=(((1:n)-0.5)/n);
scatter(sortres,norminv(pctl));
ticks=[2 10:20:90 98];
ti=norminv(ticks/100);
set(gca,'YTick',ti,'YTickLabel',ticks,'YLim',[ti(1) ti(end)]);
xlabel('Residual');
ylabel('Percentile');
title('Test for normality');