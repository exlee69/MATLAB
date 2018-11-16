function d=addcol(d,colname,col)
%DATAFRAME/ADDCOL
%d=addcol(d,colname,col)
if ischar(col), col=cellstr(col); end
if length(col)~=d.rowct, error('Can''t add column with different number of rows');end
if length(cellstr(colname))>1 | prod(size(col))~=length(col), error('Can''t add more than one column at a time'); end
d.colnames{end+1}=char(colname);
if isnumeric(col),
    t=1;
    unq=[];
elseif islogical(col),
    t=2;
    unq=[];
elseif iscellstr(col),
    t=3;
    unq=unique(col);
end
d.data{end+1}=col;
d.types(end+1)=t;
d.unqs{end+1}=unq;
d.transform(end+1)=0;
d.colct=d.colct+1;
