function [x,y,cn,yn,mod,rn,ycat,xcat,bDraw]=parsemodargs(varargin);
if isreal(varargin{end}) && length(varargin{end})==1,
    bDraw=varargin{end};
    varargin={varargin{1:(end-1)}};
else
    bDraw=1;
end
yout=[];
%ensure shape
if length(varargin)<1, error('Must have at least one argument to model'); end
d=varargin{1};
if ~isa(d,'dataframe'), error('First argument must be a dataframe'); end
x=+d;
rn=rownames(d);
cn=colnames(d);
ycat=false;
xcat=find(typematches(d,'Boolean') | typematches(d,'Category'));
mod=[];
if length(varargin)==1,
    y=depend(d);
    if typematches(y,'Boolean') || typematches(y,'Category'), ycat=true; end
    yn=colnames(y);yn=yn{1};
    y=+y;
elseif length(varargin)==2
    y=varargin{2};
    if isa(y,'model'), %prediction case
        if size(x,2)~=length(indep(y)), error('Prediction called with inputs not matching model'); end
        mod=modres(y);
        yn='Predicted y';
        return;
    elseif isa(y,'dataframe'), %separate dataframe
        yn=colnames(y);yn=yn{1};
        if typematches(y,'Boolean') || typematches(y,'Category'), meth='classification'; end
        y=+y;
        if size(x,1)~=length(y), error('dependent variable must have same # of rows'); end
    else %nargin=2
        y=y(:);
        if size(x,1)~=length(y), error('dependent variable must have same # of rows'); end
        yn=inputname(2);
    end
else %3+arguments
    error('At most two arguments allowed');
end
