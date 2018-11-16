function outd=subsref(d,s)
%DATAFRAME/SUBSREF
rows=1:d.rowct;
bRowSubscripted=0;
cols=1:d.colct;
dep=d.dep; %may or may not already be empty
bNoColsSubscript=1;
bSkip=false;
for i=1:length(s),
    if bSkip, %already picked up this term
        bSkip=false;
        continue;
    end 
    switch s(i).type
        case '()' %row subscripting
            if bRowSubscripted, error('Can''t do row () subscripting twice'); end
            if length(s(i).subs)>1,
                rows=s(i).subs;
            else
                rows=s(i).subs{1};
            end
            bRowSubscripted=1;
            if ischar(rows) && strcmp(rows,':'), %same subscripting
                dfn=inputname(1);
                eval(['global ' dfn '__lastrow;']);
                rows=eval([dfn '__lastrow']);
                if isempty(rows),
                    eval(['clear global ' dfn '__lastrow;']);
                    error('No previous subscripting for SAME row subscripting in DATAFRAME');
                end
            elseif iscellstr(rows) || ischar(rows), %rowname subscripting
                if ischar(rows), ns=1; else ns=length(rows); end % handle char vs cell
                rowlabs=rows;
                rows=zeros(ns,1);
                for j=1:ns,
                    x=strmatch(rowlabs(j),d.rownames,'exact');
                    if isempty(x), error(['Invalid row subscript ''' char(rowlabs(j)) '''']);end
                    rows(i)=min(x);
                end
            elseif islogical(rows), %boolean subscripting
                rows=find(rows);
            end
            if max(rows)>d.rowct, error('Row index greater than # of rows'); end
        case '.'
            %savecols=cols; %incase need for dependent case;
            collab=s(i).subs;
            if bNoColsSubscript && ~any(strcmpi({'dep','depend','depends','d','const'},collab)),
                cols=[]; 
                bNoColsSubscript=0; 
            end %erase default of all
            switch lower(collab),
                case 'same'
                    dfn=inputname(1);
                    eval(['global ' dfn '__lastcol;']);
                    scols=eval([dfn '__lastcol']);
                    if isempty(scols),
                        eval(['clear global ' dfn '__lastcol;']);
                        error('No previous subscripting for SAME column subscripting in DATAFRAME');
                    end
                    if isempty(cols),
                        cols=scols; %avoid setdiff processing (sort, unique) if no prior info
                    else
                        cols=[cols setdiff(scols,cols)];
                    end
                case 'const'
                    d.colnames{end+1}='const';
                    d.unqs{end+1}=[];
                    d.transform(end+1)=0;
                    d.types(end+1)=1;
                    d.data{end+1}=ones(d.rowct,1);
                    d.colct=d.colct+1;
                    cols=[cols d.colct];
                case 'poly'
                    if i==length(s) || ~strcmp(s(i+1).type,'{}'), error('Must provide {var} subscript for poly');end
                    polynames=s(i+1).subs;
                    deg=polynames{end};
                    polynames={polynames{1:(end-1)}};
                    nv=length(polynames);
                    if nv>5, error('Maximum  of 5 variables supported'); end
                    [found,idx]=ismember(polynames,d.colnames);
                    if ~all(found), error(['Invalid poly subscript (' polynames(~found) ')']); end
                    v=(0:deg)';
                    [d1,d2,d3,d4,d5]=ndgrid(v,v,v,v,v);
                    degs=[d1(:) d2(:) d3(:) d4(:) d5(:)];
                    degs=degs(1:((deg+1)^nv),1:nv);
                    tdeg=sum(degs,2);
                    bKeep=tdeg>0 & tdeg<=deg;
                    degs=degs(bKeep,:);
                    for i=1:size(degs,1),
                        d.unqs{end+1}=[];
                        d.transform(end+1)=0;
                        d.types(end+1)=1;
                        d.colct=d.colct+1;
                        cols=[cols d.colct];
                        %above was book keeping -now do actual creation of
                        %data & name
                        rdegs=degs(i,:);
                        v=ones(d.rowct,1);
                        nm='';
                        for j=1:length(rdegs),
                            if rdegs(j)>0,
                                v=v.*d.data{idx(j)}.^rdegs(j);
                                nm=[nm '*' d.colnames{idx(j)}];
                                if rdegs(j)>1, nm=[nm '^' int2str(rdegs(j))]; end
                            end
                        end
                        d.data{end+1}=v;
                        d.colnames{end+1}=nm(2:end);
                    end
                    bSkip=true;
                case {'d','dep','depend','depends'}
                    if i==length(s) || ~strcmp(s(i+1).type,'{}'), error('Must provide {var} subscript for dependent');end
                    depname=s(i+1).subs{1};
                    depcol=strmatch(depname,d.colnames,'exact');
                    if isempty(depcol), error(['Invalid dependent subscript (' depname ')']); end
                    dep={depname dotransform(d.data{depcol},d.transform(depcol)) depcol};
                    bSkip=true;
                    %warning: setdiff would be faster but reorders cols
                    idx=find(cols==depcol);
                    if ~isempty(idx), cols(idx)=[]; end
                otherwise  %actual name subscripting
                    col=strmatch(collab,d.colnames,'exact');
                    if isempty(col), 
                        error(['Invalid column subscript (' collab ')']);
                    end
                    cols=[cols col];
            end %switch collab
        otherwise
            error('Invalid subscripting of dataframe');
    end %switch s.type
end %for i
if isempty(cols), error('No columns of DATAFRAME subscripted'); end %should never hit this unless code is bad
%special case - return actual data if single column
%if length(cols)==1, %if accessing a single row
%    outd=dotransform(d.data{cols}(rows),d.transform(cols));
%    return;
%end
%otherwise, now set up for call to dataframe
%.colnames,.colct,.rowct,.types,.var1,....
outd.colnames={d.colnames{cols}};
outd.colct=length(cols);
outd.rowct=length(rows);
for i=1:length(cols),
    outd.data{i}=d.data{cols(i)}(rows);
end
outd.types=d.types(cols);
outd.unqs={d.unqs{cols}};
if isempty(d.rownames)
    outd.rownames=[];
else
    outd.rownames={d.rownames{rows}};
end
outd.transform=d.transform(cols);
if ~isempty(dep), dep{4}=rows; end
outd.dep=dep;
outd=class(outd,'dataframe');
%save subscripting
dfn=inputname(1);
eval(['global ' dfn '__lastrow;' dfn '__lastrow=[' num2str(rows(:)') '];']);
eval(['global ' dfn '__lastcol;' dfn '__lastcol=[' num2str(cols(:)') '];']);