function e=end(d,k,n)
%DATAFRAME/END
switch k,
    case 1,
        e=d.rowct;
    case 2,
        e=d.colct;
end
