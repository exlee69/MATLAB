function a=double(d,cols,rows)
%DATAFRAME/DOUBLE converts to array
if nargin<2, cols=1:d.colct; end
if nargin<3, rows=1:d.rowct; end
%if ~isempty(d.dep), cols=setdiff(cols,d.dep{3}); end %redundant
a=zeros(length(rows),length(cols));
for i=1:length(cols)
    col=cols(i);
    switch d.types(col),
        case 1,
            dat=d.data{col}(rows);
            if d.transform(col)~=0, dat=dotransform(dat,d.transform(col)); end
            a(:,i)=dat(:);
        case 2,
            a(:,i)=double(d.data{col}(rows));
        case 3,
            unqs=d.unqs{col};
            for j=1:length(rows),
                if all(isnan(d.data{col}{rows(j)})) || length(d.data{col}{rows(j)})==0,
                    a(j,i)=NaN;
                else
                    a(j,i)=strmatch(d.data{col}{rows(j)},unqs);
                end
            end
        otherwise
            error('Unknown type of variable in dataframe');
    end
end
