function [maptype,coordx,coordy]=maptype(d)
y=strmatch('lat',d.colnames,'exact');
x=strmatch('lon',d.colnames,'exact');
if ~isempty(x) && ~isempty(y),
    coordx=d.data{x};
    coordy=d.data{y};
    maptype=1;
    return;
end
x=strmatch('x',d.colnames,'exact');
y=strmatch('y',d.colnames,'exact');
if ~isempty(x) && ~isempty(y),
    coordx=d.data{x};
    coordy=d.data{y};
    maptype=2;
    return;
end
maptype=0;
coordx=[];
coordy=[];
return;
