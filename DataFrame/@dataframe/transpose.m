function dout=transpose(d)
if ~all(d.types==1), error('Can only transpose dataframes containing all doubles'); end
cn=d.colnames;
rn=rownames(d);
dat=+d;
dout=dataframe(rn',dat');
dout=rownames(dout,cn);