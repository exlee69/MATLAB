function ypred=pred(m,d)
if isempty(m.mod), ypred=repmat(NaN, size(+d)); return; end
noind=length(m.indepvars);
cn=indep(m);
bAddConst=strmatch('const',cn,'exact');
if length(cn)==1,
    bDoPoly=0;
else
    bDoPoly=regexp(cn,'[\*\^]');
    bDoPoly=~cellfun('isempty',bDoPoly);
end
if isnumeric(d) 
    if ~isempty(bAddConst) & size(d,2)+1<=noind, 
        d=insert(bAddConst,d,ones(size(d,1),1));
    end
    if any(bDoPoly) & size(d,2)+sum(bDoPoly)<=noind,
        v=find(~bDoPoly);
        for i=1:length(v), 
            if ismember(cn{v(i)},{'m','d','noind','cn','bAddConst','bDoPoly','i','v'}), error(['Name conflict in prediction: ' cn{i}]); end
            if strcmp(cn{v(i)},'const'), continue; end
            eval([cn{v(i)} '=[' num2str(d(:,i)') ']'';']); %big trouble if var is i, bDoPoly, d ,etc
        end
        for i=find(bDoPoly)',
            v=eval(vectorize(cn{i}));
            d=insert(i,d,v);
        end
    end
    if size(d,2)~=noind, error('Must provide same number of independent variables'); end
    d=dataframe(cn,d);
end
if isa(d,'dataframe'),
    if bAddConst & length(colnames(d))+1==noind, d=[d dataframe({'const'},ones(length(rownames(d)),1))]; end
    cn=colnames(d);
    if length(cn) ~=noind, error('Must provide same number of indepdendent variables');end
end
ypred=feval(m.creator,d,m);
return;

function out=insert(pos,d,col)
if pos==1,
    out=[col d];
elseif pos>size(d,2),
    out=[d col];
else
    out=[d(:,1:(pos-1)) col d(:,pos:end)];
end
