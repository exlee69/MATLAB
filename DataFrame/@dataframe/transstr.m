function s=transstr(t)
if t==0,
    s='';
elseif t<0,
    s=sprintf(' - log(+%g)',-t);
else
    switch t,
        case 1,
            s=' - log';
        case 2,
            s=' - assq';
        case 3,
            s=' - logit';
    end
end
