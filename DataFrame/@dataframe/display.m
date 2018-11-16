function s=display(d)
%DATAFRAME/DISPLAY
if (d.colct==1 && max(d.colct,d.rowct)<150), pretty(d);return;end
if (d.rowct==1 && max(d.colct,d.rowct)<150), pretty(d);return;end
disp(' ');
disp([inputname(1),' = '])
disp(' ');
fprintf('    Dataframe with %d rows with %d variables\n',d.rowct,d.colct);
types=gettypes;
if ~isempty(d.rownames),
    fprintf('    Sample rows: ');
    for i=1:min(3,length(d.rownames)),
        fprintf('%s ',d.rownames{i});
    end
    fprintf('\n');
end
fprintf('    Variables = ');
ul=min(d.colct,120);
for i=1:ul,
    if d.transform(i)~=0, con=' - '; else con=''; end
    fprintf('%s(%s%s%s)',d.colnames{i},types{d.types(i)},con,transstr(d.transform(i)));
    if i<d.colct, 
        fprintf(', '); 
        if mod(i,4)==0,fprintf('\n        ');end
    end
end
fprintf('\n');
disp(' ');