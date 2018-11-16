function pretty(m)
switch m.creator,
    case 'tree'
        printtree(m);
    otherwise
        fprintf('No pretty printing available for models of type %s\n',m.creator);
end

function printtree(m)
t=modres(m);
tr=t.tree;
fprintf('Root (N=%d, mn=%d)\n',tr.nodesize(1),tr.class(1));
printtreerec(tr,1,t.best,1,indep(m));
return;

function printtreerec(tr,node,best,lvl,varnames)
if tr.prunelist(node)<=best, return; end
indent=char(repmat(32,1,lvl*2));
lch=tr.children(node,1);
rch=tr.children(node,2);
N=tr.nodesize(lch);if N>1, sd=sqrt(tr.nodeerr(lch)*N/(N-1)); else sd=NaN; end
fprintf('%s%d) %s<%g (N=%d, mn=%g, sd=%g)\n',indent,lvl,varnames{tr.var(node)},tr.cut(node),...
    tr.nodesize(lch),tr.class(lch),sd);
printtreerec(tr,lch,best,lvl+1,varnames);
N=tr.nodesize(rch);if N>1, sd=sqrt(tr.nodeerr(rch)*N/(N-1)); else sd=NaN; end
fprintf('%s%d) %s>=%g (N=%d, mn=%g, sd=%g)\n',indent,lvl,varnames{tr.var(node)},tr.cut(node),...
    tr.nodesize(rch),tr.class(rch),sd);
printtreerec(tr,rch,best,lvl+1,varnames);
return;

      Nk = Tree.nodesize(node);
      if Nk > 1
         s = sqrt((Tree.nodeerr(node) * Nk) / (Nk - 1));
         txt = sprintf('N = %d\nMean = %g\nStd. dev. = %g',Nk,xbar,s);
      else
         txt = sprintf('N = %d\nMean = %g',Nk,xbar);
      end



