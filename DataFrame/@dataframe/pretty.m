function pretty(d)
%DATAFRAME/PRETTY
% pretty prints data
cw=get(0,'CommandWindowSize');
colw=10;
ncolsperline=floor(cw(1)/(colw+1));
if d.colct==1,
    nlines=ceil(d.rowct/ncolsperline);
    disp(d.colnames{1});
    for i=1:nlines,
        if i==nlines,  ul=d.rowct-(i-1)*ncolsperline; else ul=ncolsperline; end
        if ~isempty(d.rownames),
            for j=1:ul,
                fprintf('%*.*s ',colw,colw,d.rownames{j+(i-1)*ncolsperline});
            end
            fprintf('\n');
        end
        for j=1:ul,
            r=j+(i-1)*ncolsperline;
            if d.types==3,
                if ischar(d.data{1}{r}),
                    s=d.data{1}{r};
                else
                    s='NaN';
                end
            else
                s=sprintf('%f',d.data{1}(r));
            end
            fprintf('%*.*s ',colw,colw,s);
        end  
        fprintf('\n');
    end
else
    fprintf('\n');
    if ~isempty(d.rownames),bRows=1; else bRows=0; end
    nblocks=ceil(d.colct/(ncolsperline-bRows));
    for i=1:nblocks,
        %select columsn to print
        ll=(i-1)*(ncolsperline-bRows)+1;
        ul=ll+(ncolsperline-bRows)-1;
        if (ul>d.colct), ul=d.colct; end
        %print column names
        if bRows, fprintf('%*.*s ',colw,colw,'');end
        for c=ll:ul,
            fprintf('%*.*s ',colw,colw,d.colnames{c});
        end
        fprintf('\n');
        if bRows, fprintf('%*.*s ',colw,colw,'');end
        for c=ll:ul,
            fprintf('%*.*s ',colw,length(d.colnames{c}),repmat('-',1,colw));
        end
        fprintf('\n');
        % print data
        for r=1:d.rowct,
            if bRows, fprintf('%*.*s:',colw,colw,d.rownames{r});end
            for j=ll:ul,
                dat=d.data{j}(r);
                if isnumeric(dat)
                    s=sprintf('%g',dat);
                elseif islogical(dat)
                    if (dat),
                        s='T';
                    else
                        s='F';
                    end
                elseif iscell(dat)
                    s=dat{1};
                else
                    s='?unknown?';
                end
                fprintf('%*.*s ',colw,colw,s);
            end  % for j
            fprintf('\n');
        end % for r
        fprintf('\n');
    end % for i
    fprintf('\n');
end %if 2-D