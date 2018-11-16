function yout=regress(varargin)
%DATAFRAME\REGRESS
% regress(d)  or regress(d,y)

[x,y,cn,yn,mod,rn,xcat,ycat,bDraw]=parsemodargs(varargin{:});
if ~isempty(mod), %prediction case - already have tree
    yout=x*mod(:);
    yout=yout(:);
    return;
end

%remove nans
nans=(isnan(y) | any(isnan(x),2));
if sum(nans)>0,
    y(nans)=[];
    x(nans,:)=[];
end
n=length(y);
numparams=size(x,2);
if numparams>n, error('Overdetermined regression - # variables > # rows'); end
df=n-numparams;
if df<0, df=0; end
tstat=tinv(1-0.05/2,df);

%simple least square regresion
[Q, R]=qr(x,0);
b = R\(Q'*y);%X\y but handles ill-conditioned
yhat=x*b;
res=yhat-y;
if df==0, rmse=inf; else rmse=sqrt(sum(res.*res))/sqrt(df); end
s2=rmse^2;
RI = R\eye(numparams);
xdiag=sqrt(sum((RI .* RI)',1))';
bnorm=b./xdiag/rmse; %verify this
bci=tstat*xdiag*rmse;
bp=tcdf(bnorm,df);
bp=(0.5-abs(0.5-bp))*2;


ybar=mean(y);
RSS=sum((yhat-ybar).*(yhat-ybar));
TSS=sum((y-ybar).*(y-ybar));
r2=RSS/TSS;
if r2>1, r2=-1; warning('Regression worse than flat line'); end
r2adj=1-(1-r2^2)*(n-1)/(n-numparams);
if numparams>1, F=(RSS/(numparams-1))/s2; else F=NaN; end
p=1-fcdf(F,numparams-1,df);

%leverage
E = x/R;
if length(E)==prod(size(E)), %is vector
    h=E.*E;
else
    h = sum((E.*E)')';
end

%restore NaN rows
tmp=ones(size(nans))*NaN;
tmp(~nans)=yhat;
yhat=tmp;
tmp=ones(size(nans))*NaN;
tmp(~nans)=res;
res=tmp;
tmp=ones(size(nans))*NaN;
tmp(~nans)=y;
y=tmp;
tmp=ones(length(nans),size(x,2))*NaN;
tmp(~nans,:)=x;
x=tmp;

if bDraw,
    fprintf('Regression: r2=%g, adj r2=%g, n=%g, F=%g, p(H0)=%g\n\n',r2,r2adj,n,F,p);
    prettyarray([b,b-bci,b+bci,bnorm,bp],{'Coef','Lo','Hi','Std','P'},cn);
    
    [junk,idx]=sort(-h);
    ul=min(10,ceil(0.1*n));
    fprintf('\nMost leveraged points\n');
    for i=1:ul,
        fprintf('%20s  %g\n',rn{idx(i)},h(idx(i)));
    end
end

%add Durbin-Watson (residual correlation) & residual normality tests

yout=model(y,yhat,b,cn,'regress',[r2 r2adj,F,p],yn,x,rn);


