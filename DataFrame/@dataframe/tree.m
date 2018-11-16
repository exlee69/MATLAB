function yout=tree(varargin)
%DATAFRAME\TREE
% tree(d)  or tree(d,y)

[x,y,cn,yn,mod,rn,ycat,xcat,bDraw]=parsemodargs(varargin{:});
if ~isempty(mod), %prediction case - already have tree
    yout=treeval(mod.tree,x,mod.best);
    yout=yout(:);
    return;
end

fprintf('Calculating tree ... ');
%WARNING - need to use catidx & method appropriately
t=treefit(x,y,'catidx',xcat,'method','regression');%'classification' giving divide by zero in treefit:247
fprintf('Calculating optimal prune ...');
[c,s,n,best]=treetest(t,'cross',x,y);
fprintf('Completed ...\n');
[lowc,opt]=min(c);
if c(1)-s(1)>lowc+s(opt) && c(2)-s(2)>lowc+s(opt) && abs(opt-best)>3,%&& abs(opt-best)/length(c)>.1, %biggest trees much worse than optimum?
        fprintf('Choosing lowest cost prune %d, formal optimal is %d\n',opt,best);
        best=opt;
end
minnodes=5;
if n(best)<minnodes,
    opt=find(n>minnodes);
    if ~isempty(opt),
        best=opt(end)-1;
    else
        best=length(n)-1;
    end
    fprintf('Forcing at least five nodes\n');
end
if bDraw,
    %prettyarray([c s n (1:length(n))'==best],{'Cost','SE(cost)','#nodes','optimum'});
    %t=treeprune(t,'level',best);
    %fprintf('\n');
end
yhat=treeval(t,x,best);

tree.tree=t;
tree.best=best;
tree.c=c;
tree.s=s;
tree.n=n;

yout=model(y,yhat,tree,cn,'tree',[],yn,x,rn);