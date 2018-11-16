function summary(d)
%dataframe/summary
types=gettypes;
dat=+d;
[r,c]=size(dat);
ct=sum(isfinite(dat),1);
for i=1:d.colct,
        s=sprintf('%s(%s%s)',d.colnames{i},types{d.types(i)},transstr(d.transform(i)));
        fprintf('%20.20s: ',s);
        fprintf('N=%4d (%5.1f%%) ',ct(i),ct(i)/r*100);
        switch d.types(i),
            case 1 %numeric
                nanfree=dat(:,i);nanfree(isnan(nanfree))=[];
                mu=mean(nanfree);
                if std(nanfree,1)==0, skew=NaN; else skew=mean((nanfree-mu).^3)/std(nanfree,1)^3; end
                fprintf('mn=%5g+-%5g (med=%5g)  range=(%5g,%5g) skew=%5g\n',...
                    mu,std(nanfree),median(nanfree),min(nanfree),max(nanfree),skew);
            case 2 %boolean
                nt=sum(dat(:,i));
                fprintf('%d (%g%%) true\n',nt,nt/ct(i)*100);
            case 3 %category
                cn=catnames(d,i);
                for j=1:length(cn),
                    m=sum(dat(:,i)==j);
                    fprintf('''%s'' (%d/%4.1f%%) ',cn{j},m,m/ct(i)*100);
                end
                fprintf('\n');
        end
end