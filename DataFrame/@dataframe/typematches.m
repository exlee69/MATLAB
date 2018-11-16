function b=typematches(d,s)
%dataframe\typematches
t=gettypes;
if nargin<2 || ~ischar(s), error('Must specify a string for type'); end
typ=strmatch(lower(s),lower(t));
if isempty(typ), error(['Invalid type to match ' s]);end
b=d.types==typ;