function o=horzcat(varargin)
%DATAFRAME/HORZCAT
if nargin==1,
    o=varargin{1};
elseif nargin==2,
    o=cat2(varargin{1},varargin{2});
else
    o=horzcat(cat2(varargin{1},varargin{2}),varargin{3:end});
end

function d=cat2(d1,d2)
if isempty(d2), d=d1; return; end
if d1.rowct~=d2.rowct, error('Can''t horzcat dataframes with different # of rows'); end
d.colnames={d1.colnames{:} d2.colnames{:}};
d.colct=d1.colct+d2.colct;
d.rowct=d1.rowct;
d.data={d1.data{:} d2.data{:}};
d.types=[d1.types d2.types];
d.unqs={d1.unqs{:} d2.unqs{:}};
if ~isempty(d1.rownames),
    d.rownames=d1.rownames;
else
    d.rownames=d2.rownames;
end
d.transform=zeros(1,d.colct);
d.dep=[];
d=class(d,'dataframe');
