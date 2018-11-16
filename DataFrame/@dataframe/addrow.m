function d=addrow(d,row,rowlab)
%DATAFRAME/ADDROW
% d=addcol(d,row[,rowlab])
%.colnames,.colct,.rowct,.data,.types,.unqs,.rownames
if nargin<3 & ~isempty(d.rownames), error('Must provide rowname to add row'); end
if nargin>=3 & isempty(d.rownames), error('Cannot provide rowname when adding row'); end
row={row{:}}';
if length(row)~=d.colct, error('Must provide correct number of columns when adding row'); end
for i=1:d.colct,
    switch d.types(i),
        case 1, %double
            dat=double(row{i});
            d.data{i}=[d.data{i}(:);double(dat(1))];
        case 2, %logical
            dat=logical(row{i});
            d.data{i}=[d.data{i}(:);logical(dat(1))];
        case 3, %group
            dat=cellstr(row{i});
            d.data{i}={d.data{i}{:} char(dat(1))};
            if ~ismember(char(dat(1)),d.unqs{i}),
                d.unqs{i}={d.unqs{i}{:} char(dat(1))};
            end
    end
end
if nargin>=3, d.rownames{end+1}=char(rowlab); end
d.rowct=d.rowct+1;