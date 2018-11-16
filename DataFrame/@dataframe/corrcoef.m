function corr(d)
dat=+d;
cn=colnames(d);
[r,p]=corrcoef(dat);
vs=1:length(r);
[X,Y]=meshgrid(vs,vs);
Y=flipud(Y);
figure;
xlabel('');ylabel('');
colormap([1 0.25 0.25; 0.25 1 0.25]);
c=repmat(1,length(r),length(r));
c=c(:);
c(find(r(:)<0))=0;
caxis([0 1]);
sz=abs(r)*20^2;
sz=sz-triu(sz,1)*.999999;
sz=sz(:);
sz(find(sz==0))=0.000001;
scatter(X(:),Y(:),sz,c,'filled');
set(gca,'XTick',[0 vs],'YTick',[0 vs],'XTickLabel',{'' cn{:}},'YTickLabel',fliplr({cn{:} ''}));
axis([0 length(r) 0 length(r)]);
ul=length(r);
for i=1:ul,
    for j=(i+1):ul,
        s=sprintf('%.2g',r(i,j));
        sig='';
        if p(i,j)<0.05, sig='*'; end
        if p(i,j)<0.01, sig='**'; end
        if p(i,j)<0.001, sig='***';end
        s=[s sig];
        h=text(j,ul+1-i,10,s);
        set(h,'HorizontalAlignment','Center','VerticalAlignment','middle');
    end
end
        
