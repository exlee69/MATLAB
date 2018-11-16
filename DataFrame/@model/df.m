function df=df(m)
if isempty(m.mod), df=NaN; return; end
df=length(m.mod);
switch m.creator
    case 'tree'
        t=m.mod;
        df=t.n(t.best+1)-1; %+1 for 0=no prune, -1 for #splits = #term nodes-1
end
