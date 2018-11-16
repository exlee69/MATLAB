function yhat=kernsmooth(x,y,band)
yhat=zeros(size(x));
if all(x==x(1)), yhat=yhat+mean(y); return;end
x=x(:);y=y(:);
n=length(x);
for i=1:n,
    wts=1/sqrt(2*pi*band^2)*exp(-((x(i)-x)/band).^2/2);
    adjx=x-x(i);
    m0=sum(wts)/n;
    m1=sum(adjx.*wts)/n;
    m2=sum(adjx.^2.*wts)/n;
    if all(wts(setdiff(1:n,i))==0), 
        warning(['KERNELSMOOTH: Outlier at x=' num2str(x(i)) ', y=' num2str(y(i)) ' has no points to smooth with']); 
        yhat(i)=y(i);
    else
        yhat(i)=sum(((m2-m1*adjx).*wts.*y)/(m2*m0-m1*m1))/n;
    end
end
return;