function yout=logit(varargin)
%DATAFRAME\LOGIT
% logit(d)  or logit(d,y)

[x,y,cn,yn,mod,rn,ycat,xcat,bDraw]=parsemodargs(varargin{:});
if ~isempty(mod), %prediction case - already have tree
    yout=glmval(mod,x(:,2:end),'logit'); %chop out constant
    yout=yout(:);
    return;
end

yunq=unique(y);
if length(yunq)~=2, error('Must provide two category input to LOGIT'); end
y=(y==yunq(end));


%remove nans
nans=(isnan(y) | any(isnan(x),2));
if sum(nans)>0,
    y(nans)=[];
    x(nans,:)=[];
end
n=length(y);
numparams=size(x,2)+1; %constant always added
cn={'const' cn{:} }; % and always at front


[b,dev,stat]=glmfit(x,[y ones(size(y))],'binomial');
yhat=glmval(b,x,'logit');

%calc r2
df=stat.dfe;
ybar=mean(y);
RSS=sum((yhat-ybar).*(yhat-ybar));
TSS=sum((y-ybar).*(y-ybar));
r2=RSS/TSS;
r2adj=1-(1-r2^2)*(n-1)/df;

if bDraw,
    fprintf('Regression: r2=%g, adj r2=%g, %%correct=%g%%, dev=%g, dispers=%g\n\n',r2,r2adj,sum(y==(yhat>=0.5))/length(y)*100,dev,stat.sfit);
    tstat=tinv(1-0.05/2,df);
    prettyarray([stat.beta,stat.beta-tstat*stat.se,stat.beta+tstat*stat.se,stat.t,stat.p],{'Coef','Lo','Hi','t','P'},cn);
end

yout=model(y,yhat,b,cn,'logit',[],yn,x,rn);