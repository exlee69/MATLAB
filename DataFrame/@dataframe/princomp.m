function df=princomp(d,nv)
%dataframe\princomp

if nargin<2, nv=5; end

bmet=typematches(d,'metric');
dat=+d;
dat=dat(:,bmet);
cn={d.colnames{find(bmet)}};
rn=rownames(d);

[r,c]=size(dat);
if r<c, error('Can''t do principle components on data with too few rows'); end
dat=dat./repmat(std(dat),d.rowct,1);
mu=mean(dat);
stand=(dat-mu(ones(r,1),:));
[junk,sv,pc]=svd(stand./sqrt(r-1),0);
scores=stand*pc;
lambda=diag(sv).^2;
hot=sqrt(diag(1./lambda))*scores';
hot=sum(hot.*hot);

figure;
subplot(2,1,1);
h=scatter(scores(:,1),scores(:,2),'+');
%axis square;
xlabel('\fontsize{14}PC1');
ylabel('\fontsize{14}PC2');
dolines;
subplot(2,1,2);
h=scatter(scores(:,1),scores(:,3),'+');
%axis square;
xlabel('\fontsize{14}PC1');
ylabel('\fontsize{14}PC3');
dolines;

if c<nv,
    npc=c;
else
    npc=nv;
end
pcs=[lambda(1:npc)';(100*(lambda(1:npc)/sum(lambda)))';pc(:,1:npc)]';
prettyarray(pcs,{'lambda','% var',cn{:}},cellstr(num2str((1:npc)','PC %2d')));

nout=min(10,c);
fprintf('\n\nOutliers\n---------------\n');
[shot,idx]=sort(-hot);
for i=1:nout
    fprintf('%2d - %s (%g)\n',i,rn{idx(i)},-shot(i));
    subplot(2,1,1);
    pc1=scores(idx(i),1);
    pc2=scores(idx(i),2);
    pc3=scores(idx(i),3);
    if pc1>0, ha='Left'; else ha='Right'; end
    if pc2>0, va='Bottom'; else va='Top';end
    set(text(pc1,pc2,rn{idx(i)}),'HorizontalAlignment',ha,'VerticalAlignment',va);
    subplot(2,1,2);
    if pc3>0, va='Bottom'; else va='Top';end
    set(text(pc1,pc3,rn{idx(i)}),'HorizontalAlignment',ha,'VerticalAlignment',va);
end

if nargout>0,
    df=dataframe(cellstr(strcat('PC',num2str((1:size(scores,2))'))),scores);
end



function dolines
h=line(get(gca,'XLim'),[0 0]);
set(h,'LineStyle','-.','Color','k');
h=line([0 0],get(gca,'YLim'));
set(h,'LineStyle','-.','Color','k');