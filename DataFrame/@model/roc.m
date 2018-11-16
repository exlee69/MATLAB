function area=roc(m,bDraw)
% RECEIVER OPERATOR CURVE
yhat=yhat(m);
yact=yact(m);

if min(yhat)<0 || max(yat)>1 || any(yact~=0 && yact~=1),
    error('ROC only calculated on binary dependent data');
end