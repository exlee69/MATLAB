function out=yhat(m)
if isempty(m.mod), out=NaN; return; end
out=m.yhat;