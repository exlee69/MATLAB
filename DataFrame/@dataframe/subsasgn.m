function d=subasgn(d,s,val)
%DATAFRAME/SUBSREF
rows=1:d.rowct;
bRowSubscripted=0;
cols=1:d.colct;
bNoColsSubscript=1;
for i=1:length(s),
    switch s(i).type
        case '()' %row subscripting
            if bRowSubscripted, error('Can''t do row () subscripting twice'); end
            rows=s(i).subs{1};
            if length(s(i).subs)>1, %possible column subscripting
                error('Column subscripting not currently supported')
            end
            bRowSubscripted=1;
            if iscellstr(rows) | ischar(rows), %rowname subscripting
                if ischar(rows), ns=1; else ns=length(rows); end % handle char vs cell
                rowlabs=rows;
                rows=zeros(ns,1);
                for i=1:ns,
                    x=strmatch(rowlabs(i),d.rownames);
                    if isempty(x), error(['Invalid row subscript ''' rowlabs(i) '''']);end
                    rows(i)=min(x);
                end
            end
            if max(rows)>d.rowct, error('Row index greater than # of rows'); end
        case '.'
            if bNoColsSubscript, cols=[]; bNoColsSubscript=0; end %erase default of all
            col=strmatch(s(i).subs,d.colnames);
            if isempty(col), error(['Invalid column subscript (' s(i).subs ')']);end
            cols=[cols col];
        otherwise
            error('Invalid subscripting of dataframe');
    end
end
if ischar(val), val=cellstr(val); end
if size(val,2)==1 & length(cols)>1, val=repmat(val,1,length(cols)); end
if size(val,1)==1 & length(rows)>1, val=repmat(val,length(rows),1); end
if size(val,2)~=length(cols), error('Number of columns subscripted ne data cols'); end
if size(val,1)~=length(rows), error('Number of rows subscripted ne data rows');end
for c=1:length(cols),
    switch d.types(cols(c)),
        case 1, %double
            d.data{cols(c)}(rows)=val(:,c);
        case 2, %logical
            w=warning('off','MATLAB:conversionToLogical');
            d.data{cols(c)}(rows)=val(:,c);
            warning(w.state,'MATLAB:conversionToLogical');
        case 3, %group
            if ~iscell(val), error('Can''t assign non-group to group'); end
            if length(val)==1,
                d.data{cols(c)}{rows}=val{1,1}; 
            else
                d.data{cols(c)}(rows)={val{:,c}}';
            end
            if length(union(val,d.unqs{cols(c)}))~=length(d.unqs{cols(c)}),
                %added groups - place at end
                toadd=~ismember(val,d.unqs(cols(c)));
                d.unqs{cols(c)}={d.unqs{cols(c)}{:} val{toadd}};
            end
        end
end