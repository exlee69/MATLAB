function attach(d,bClear)
if nargin<2, bClear=0; end
%DATAFRAME/ATTACH
%attach(df) spits variables out into workspace
for i=1:d.colct,
    vname=regexprep(d.colnames{i},'\s*','_'); %replace whitespace
    vname=regexprep(vname,'\W',''); %eliminate punctuation,etc
    if bClear,
        evalin('base',['clear ' vname]);
    else
        v=d.data{i};
        if d.transform(i)~=0, v=dotransform(v,d.transform(i)); end
        assignin('base',vname,v);
    end
end