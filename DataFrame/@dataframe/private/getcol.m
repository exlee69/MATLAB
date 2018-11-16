function outcols=getcol(d,cols)
if isnumeric(cols)
    outcols=cols;
elseif iscellstr(cols) || ischar(cols)
    outcols=strmatch(cols,d.colnames);
else
    error('Invalid argument to getcol');
end