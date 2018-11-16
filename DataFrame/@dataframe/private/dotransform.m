function odat=dotransform(dat,t)
if t<0,
    odat=log10(dat+-t);
elseif t>0,
    switch t,
        case 1,
            odat=log10(dat);
        case 2,
            odat=asin(sqrt(dat));
        case 3,
            odat=dat./(1-dat);
    end
else
    odat=dat;
end
