function dout=depend(d)
%DATFRAME\dep
% df=dep(d) returns dependent variable as a dataframe
dep=d.dep;
if isempty(dep),
    dout=[];
    return;
end
dout=dataframe(d.dep(1),d.dep{2}(d.dep{4}));