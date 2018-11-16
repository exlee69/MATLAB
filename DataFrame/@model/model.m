function m=model(yact,yhat,mod,indepvars,creator,fits,yn,x,rownames)
if nargin==0, m=model([],[],[],[],[],[],[]);return; end
if nargin~=9, error('Model must have 9 arguments'); end
m.yact=yact;
m.yhat=yhat;
m.mod=mod;
m.indepvars=indepvars;
m.creation=clock;
m.creator=creator;
m.fits=fits;
m.yn=yn;
m.x=x;
m.rownames=rownames;
m=class(m,'model');