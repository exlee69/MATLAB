function d=rownames(d,a)
%DATAFRAME/ROWNAMES
%
%rownames(d,n) turns n'th column into rownames
%rownames(d,cellstr) adds rownames
%rownames(d) returns rownames
if nargin>=2,
    if length(a)==1 & isnumeric(a), %turn column into rownames
        d.colnames(a)=[];
        d.rownames=d.data{a};
        d.data(a)=[];
        d.colct=d.colct-1;
        d.types(a)=[];
        d.unqs(a)=[];
    elseif ischar(a),
        col=strmatch(a,d.colnames);
        if isempty(col), error(['Invalid column name (' a ') passed to ROWNAMES']); end
        d=rownames(d,col);
    elseif isnumeric(a) & length(a)==d.rowct,
        d.rownames=cellstr(num2str(a));
    elseif iscellstr(a) & length(a)==d.rowct,
        d.rownames=a;
    elseif isempty(a)
        d.rownames=[];
    else
        error('Invalid rownames input');
    end
else
    if isempty(d.rownames),
        %make em up so we always return a cellstr
        d=cellstr(num2str((1:d.rowct)','Row %4d'));
        %d=cellstr(int2str((1:d.rowct)'));
    else
        d=d.rownames;
    end
end
    