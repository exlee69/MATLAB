function r2=r2(m)
if isempty(m.mod), r2=NaN; return; end
b=isnan(m.yact)|isnan(m.yhat);
yact=m.yact(~b);
yhat=m.yhat(~b);
mn=mean(yact);
delta=yact(:)-yhat(:);
r2=1-sum(delta.*delta)/sum((yact-mn).*(yact-mn));