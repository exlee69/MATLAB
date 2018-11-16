function boxplot(d)
%datframe/boxplot
bmet=typematches(d,'metric');
dat=+d;
dat=dat(:,bmet);
cn={d.colnames{find(bmet)}};
boxplot(dat,1,'+',0);
set(gca,'YTickLabel',cn);
ylabel('');
