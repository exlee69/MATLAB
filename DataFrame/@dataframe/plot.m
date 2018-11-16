function plot(d,varargin)
%dataframe/plot
dep=depend(d);
cn=colnames(d);
dat=+d;
[r,c]=size(dat);
if isempty(dep), %scatterplot case
    [H,AX,BigAx,P,PAx] = plotmatrix(dat);
    for i=1:length(P),
        subplot(AX(i,1));
        ylabel(['\fontsize{14}' cn{i}]);
        subplot(AX(end,i));
        xlabel(['\fontsize{14}' cn{i}]);
    end
else %depends on case
    ydat=+dep;
    yname=char(colnames(dep));
    switch c,
        case 1
            plots=[1 1];
        case 2
            plots=[2 1];
        case {3,4}
            plots=[2 2];
        case {5,6}
            plots=[3 2];
        case {7,8}
            plots=[2 4];
        case {9,10,11,12}
            plots=[3 4];
        otherwise
            plots=[4 4];
    end
    if c>16, c=16; end
    band=0.5;
    if length(varargin)>=1 && isnumeric(varargin{1}) && varargin{1}(1)>0 && varargin{1}(1)<=1,
        band=varargin{1}(1);
        varargin={varargin{2:end}};
    end
    for i=1:c,
        subplot(plots(1),plots(2),i);
        [x,idx]=sort(dat(:,i));
        y=ydat(idx);
        yhat=kernsmooth(x,y,band);
        plot(x,y,'o',x,yhat,'-',varargin{:});
        set(gca,'FontSize',14);
        xlabel(['\fontsize{14}' cn{i}]);
        if mod(i,plots(2))==1 || plots(2)==1, ylabel(['\fontsize{14}' yname]); end
    end
end

