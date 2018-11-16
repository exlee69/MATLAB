function plot(m,bName)
if nargin<2, bName=0; end
switch m.creator
    case 'tree'
        tr=modres(m);
        treedisp(tr.tree,'names',indep(m),'prunelevel',tr.best);
        set(0,'ShowHiddenHandles','on');
        f=gcf;
        set(0,'ShowHiddenHandles','off');
        set(f,'Name',['CART tree: ' dep(m)]);
        figure;
        h1=errorbar(tr.n,tr.c,tr.s,'b-');
        hold on;
        h2=plot(tr.n(tr.best+1),tr.c(tr.best+1),'rx');
        set(gca,'FontSize',14);
        ylabel('Residual variance');
        xlabel('# terminal nodes');
        legend([h1(1) h2],'Cross-validation error','Estimated best tree size');
    case 'regress'
        i=indep(m);
        c=strmatch('const',i);
        actlength=length(i);
        if ~isempty(c), actlength=actlength-1; end
        switch actlength,
            case 1,
                plot1dline(m,i,c);
                 if bName,gname(m.rownames); end
           case 2,
                figure;
                x=m.x;
                if ~isempty(c), x(:,c)=[]; end
                yact=yact(m);
                stem3(x(:,1),x(:,2),yact,'o');
                xl=get(gca,'XLim');
                yl=get(gca,'YLim');
                [X,Y]=meshgrid(linspace(xl(1),xl(2),20),linspace(yl(1),yl(2),20));
                b=modres(m);
                const=0; if ~isempty(c); const=b(c); b(c)=[]; end
                Z=X*b(1)+Y*b(2)+const;
                hold on;
                mesh(X,Y,Z);
                hold off;
                nms=indep(m);
                xlabel(['\fontsize{16}' nms{1}]);
                ylabel(['\fontsize{16}' nms{2}]);
                figure;
                subplot(2,1,1);
                plot1part(m,c,1);
                subplot(2,1,2);
                plot1part(m,c,2);
            otherwise
                residplot(m);
        end
end

function plot1dline(m,i,c)
b=modres(m);
if isempty(c),
    x=yhat(m)/b(1);
else
    x=(yhat(m)-b(c))/b(3-c);
end
y=yact(m);
figure;
scatter(x,y);
xl=get(gca,'XLim');
yl=pred(m,xl(:));
set(line(xl,yl),'LineStyle','--','Color','r');
set(gca,'FontSize',14);
xlabel(i(3-c));
ylabel(dep(m));
if isempty(c),
    title([dep(m) '=' num2str(b) '*' i{1}]);
else
    title([dep(m) '=' num2str(b(c)) ' + ' num2str(b(3-c)) '*' i{3-c}]);
end

function plot1part(m,cidx,xidx)
x=m.x;
b=modres(m);
yhat=yhat(m);
const=0;
%if ~isempty(cidx), x(:,cidx)=[];const=b(cidx);b(cidx)=[]; end
plot(x(:,xidx),yhat,'o');
xl=get(gca,'XLim');
xgrid=linspace(xl(1),xl(2),100)';
xpred=repmat(nanmean(x),length(xgrid),1);
xpred(:,xidx)=xgrid;
hold on;
ygrid=pred(m,xpred);
plot(xgrid,ygrid,'r--'); 
hold off;
set(gca,'FontSize',14);
nms=indep(m);
xlabel(nms{xidx});
ylabel(dep(m));
