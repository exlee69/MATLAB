function n=colnames(d,bTrans)
%DATAFRAME/COLNAMES
if nargin<=1 || ~bTrans,
    n=d.colnames;
else
    for i=1:d.colct,
        n{i}=[d.colnames{i} '(' transstr(d.transform(i)) ')'];
    end
end