function b=sample(d,n,bResamp)
%b=sample(d,N|pct[,bResample])

if nargin<3, bResamp=0; end
if nargin<2, n=0.5; end

N=d.rowct;

if n<1, n=N*n; end
n=round(n);
if n<=0 || (n>N &&~bResamp), error('Cant sample 0 or >N cases'); end

if bResamp,
    b=ceil(rand(n,1)*N);
else
    i=randperm(N);
    i=i(1:n);
    b=zeros(N,1);
    b(i)=1;
    b=logical(b);
end