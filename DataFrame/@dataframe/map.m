function map(d,b)
dep=depend(d);
cn=colnames(d);
dat=+d;
[mt,xcoord,ycoord]=maptype(d);
%
%need to move code over so no external references
%
if mt>0, %map
    miny=min(ycoord(:));
    maxx=max(xcoord(:));
    if nargin>1, %boolean or size
        b=b(:); if length(b)~=length(xcoord), error('Input vector must be same shape as data'); end
        if all(b==1 | b==0), 
            nsize=4; 
            b=logical(b);
            xcoord=xcoord(b);
            ycoord=ycoord(b);
            mark='o';
            color=[0,0,1];
        else 
            nsize=b/max(b)*4; 
            mark='filled';
            color=b;
        end
        if mt==1,
            latlonzplot(ycoord,xcoord,[],1);
            %drawcountry;
            %hold on;
            %scatterm(ycoord,xcoord,4^2,color,mark);
        else
            scatter(ycoord,xcoord,4^2,color,mark);
        end
    else %surface with dependent
        if isempty(dep), error('Must provide 2nd vector or dependent variable to map'); end
        ydat=+dep;
        if mt==1, %lat/lon
            latlonzplot(ycoord,xcoord,ydat,miny>10 & maxx<-30);
        else
            xyzsurf(xcoord,ycoord,ydat);
        end
    end
else
    error('No coordinates (lat/lon or x/y) found in dataframe');
end
