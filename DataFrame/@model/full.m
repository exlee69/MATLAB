function mout=full(m,lvl)
if nargin<2, lvl=0; end
if ~strcmp(m.creator,'tree'), error('Full currently only supported for tree'); end
t=modres(m);
if lvl>0,
    lvl=interp1(t.n,1:length(t.n),lvl,'nearest');
elseif lvl==-1,
    [junk,lvl]=min(t.c);
else %lvl==0, pass it through
end
t.best=lvl;
m.yhat=repmat(NaN,size(m.yhat)); %ideally something better, but at least no erroneous results
mout=model(m.yact,m.yhat,t,m.indepvars,m.creator,m.fits,m.yn);