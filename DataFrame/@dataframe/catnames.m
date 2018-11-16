function o=catnames(d,col)
%dataframe\catnames
if length(col)>1 && ~ischar(col), error('Can only fetch category names for one column at a time'); end
col=getcol(d,col);
if d.types(col)==3,
    o=d.unqs{col};
else
    error('Can''t fetch category names for non-category column');
end