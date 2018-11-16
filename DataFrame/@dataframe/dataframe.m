function d=dataframe(a,varargin)
%DATAFRAME dataframe class constructor
%   d=dataframe("file"[,delim,skiprows])
% or
%   d=dataframe(colnamescell,var1,var2,...)

%properties
%.colnames,.colct,.rowct,.data,.types,.unqs,.rownames

%enhancements
% formula - set up graphs how?
% override regress, summary, plot, ???
% pull from file
% time for rownames
% ordered char vectors - just change unq, union of cellstrs can determine
%                  if new list same as old
% NaN or '' in category fields
% rownames function (convert column)
% attach - dump data into separate variables
% pull from vars in caller
% pull from excel
% colname function to change column names & fetch names
% write to file
% modify explr to work on dataframe instead
% rbind

if nargin==0, error('dataframe function requires arguments');end
if nargin>=1 && ischar(a) && size(a,1)>1,
    a=cellstr(a);
end
if nargin<1, %suck in vectors from workspace
    s=evalin('base','whos');
    %get length of all vectors
    l=[];idx=[];
    for i=1:length(s),
        sz=s(i).size;
        if length(sz)==2 && prod(sz)==max(sz),
            l=[l max(sz)];
            idx=[idx i];
        end
    end
    u=unique(l);
    pos=findmatch(l,u);
    ct=consol(ones(size(pos)),pos);
    [nu,maxidx]=max(ct);
    comlen=u(maxidx);
    vars=idx(l==comlen);
    colnames={};
    dat={};
    for i=vars,
        colnames={colnames{:} s(i).name};
        dat={dat{:} evalin('base',s(i).name)};
    end
    d=dataframe(colnames,dat{:});
    return;
elseif ischar(a),
    lf = sprintf('\n'); % line feed is platform dependant
    if strcmpi(a,'excel'),
        % find what the selection is
        c=ddeinit('excel','system');
        sheet=ddereq(c,'Selection',[1 1]);
        ref=sheet(findstr(sheet,'!')+1:end);
        sheet=sheet(findstr(sheet,']')+1:findstr(sheet,'!')-1);
        if sheet(end)=='''', sheet=sheet(1:(end-1)); end % get extra ' if space in file/sheet name
        ddeterm(c);
        
        % get it
        c=ddeinit('excel',sheet);
        txt=ddereq(c,ref,[1 1]);
        ddeterm(c);
        dlm=9;
    elseif ~isempty(regexp(a,'tp://','ONCE')), %should pick up http:// and ftp://
        txt=urlread(a);
        dlm=',';
    else %read file
        fid = fopen(a,'rt');
        if fid == -1
            error('Unable to open file.');
        end
        % now read in the data
        [txt,count] = fread(fid,Inf);
        if txt(count) ~= lf
            txt = [txt; lf];
        end
        dlm=',';
    end
    %parse other arguments
    skiplines=0;
    skipcols=[];
    for i=1:length(varargin),
        if isnumeric(varargin{i}) && length(varargin{i})==1,
            skiplines=varargin{i};
        elseif isnumeric(varargin{i}),
            skipcols=varargin{i};
        elseif ischar(varargin{i}),
            dlm=varargin{i};
        else
            error(['Invalid argument ''' varargin{i} '''to excel/fileread version of dataframe creator']);
        end
    end
    d=txttodf(txt,dlm,skipcols,skiplines,lf);
elseif iscellstr(a),
    if length(unique(a))~=length(a), error('All column names must be unique'); end
    d.colnames=a;
    d.colct=length(a);
    if length(varargin)==1,
        d.rowct=size(varargin{1},1);
        if size(varargin{1},2)~=d.colct, error('Input array must have same # of columns as labels'); end
        for i=1:d.colct,
            d.data{i}=varargin{1}(:,i);
        end
    else
        if length(varargin)~=d.colct, error('Must provide one vector for each colname');end
        d.rowct=length(varargin{1});
        for i=1:d.colct,
            if length(varargin{i}(:))~=d.rowct, error('All vectors must be the same length'); end
            d.data{i}=varargin{i}(:);
        end   
    end
elseif isa(a,'dataframe')
    d=a;
    return;
elseif isnumeric(a),
    [r,c]=size(a);
    cn=strcat('col',num2str((1:c)'));
    d=dataframe(cn,a);
else
    error('Invalid syntax to DATAFRAME: first argument must be string or cellstring array');
end
%get types
d.types=repmat(NaN,1,d.colct);
d.unqs=cell(1,d.colct);
for i=1:d.colct,
    if isnumeric(d.data{i}),
        d.types(i)=1;
    elseif islogical(d.data{i}),
        d.types(i)=2;
    elseif all(cellfun('isclass',d.data{i},'char')|(cellfun('isclass',d.data{i},'double')&cellfun('prodofsize',d.data{i})==1)),
        %is basically a cellstr with NaN's stuck in
        d.types(i)=3;
        bNotNan=cellfun('isclass',d.data{i},'char');
        d.unqs{i}=unique(d.data{i}(bNotNan));
    end
end
d.rownames=[];
d.transform=zeros(1,d.colct);
d.dep=[];


%make sure we're a class
if ~isa(d,'dataframe'), d=class(d,'dataframe');end

function d=txttodf(txt,dlm,skipcols,skiprows,lf)
txt=txt(:);
%find # rows
newlines = [0 find(txt == lf)'];
dolines=(skiprows+1):(length(newlines)-1);
numrows=length(dolines);

%find #cols
firstline=txt(newlines(skiprows+1)+1:newlines(skiprows+2)-1)';
s=split(firstline,dlm);
cols=setdiff((1:length(s)),skipcols);
numcols=length(cols);

%create outarray
out=cell(numrows,numcols);
%fill outarray
for i=dolines
   line=txt((newlines(i)+1):(newlines(i+1)-1))';
   s=split(line,dlm);
   if length(s)~=numcols,
       warning(['Invalid # of columns in row ' int2str(i) ' - ignoring line']);
   else
       out(i-skiprows,:)={s{:}}; 
   end
end

%strip off headers
colnames={out{1,:}};
out(1,:)=[];
numrows=numrows-1;

%OK, now turn into cell of columns
cols=cell(1,numcols);
for i=1:numcols,
    c={out{:,i}};
    num=str2double(c);
    idxtruenan=union(strmatch('NaN',c,'exact'),strmatch('NA',c,'exact'),strmatch('N/A',c,'exact'));
    truenan=logical(zeros(size(num)));truenan(idxtruenan)=true;
    idxempty=strmatch('',c,'exact');
    trueempty=logical(zeros(size(num)));trueempty(idxempty)=true;
    idxbool=union(union(strmatch('T',upper(c),'exact'),strmatch('TRUE',upper(c),'exact')),union(strmatch('F',upper(c),'exact'),strmatch('FALSE',upper(c),'exact')));
    truebool=logical(zeros(size(num)));truebool(idxbool)=true;
    bools=strmatch(upper(c),'T');
    bools(~truebool)=NaN;
    truenum=~isnan(num);
    truestring=~truenum&~trueempty&~truenan&~truebool;
    cf=0.9*(numrows-sum(trueempty)-sum(truenan));
    if sum(truebool)>0 && sum(truebool)+sum(num==0 | num==1)>cf, %boolean
        d=zeros(size(num)); 
        d(num==0 | num==1)=num(num==0 | num==1);
        bval=strcmpi(upper(c(truebool)),'T')|strcmpi(upper(c(truebool)),'TRUE');
        d(truebool)=bval;
        cols{i}=logical(d); %implicitly NaN/Empty -> false since logicals don't hold NaN a problem??
    elseif num(~trueempty&~truenan)==0 || num(~trueempty&~truenan)==1
        num(isnan(num))=0; %for now keep in accord with above - NaN=False
        cols{i}=logical(num);
    elseif sum(truenum)>cf, %numeric
        cols{i}=num;
    elseif length(unique(c(~trueempty&~truenan)))<=0.7*sum(~trueempty&~truenan), %groups - the 0.7 is a bit arbitrar
        dat=c;
        if sum(trueempty)>0, dat(trueempty)={NaN}; end
        if sum(truenan)>0, dat(truenan)={NaN};end
        cols{i}=dat;
    else
        warning(['Can''t parse column #' int2str(i) 'into type']);
        cols{i}=c;
    end
end
d=dataframe(colnames,cols{:});


function cells=split(str,delim)
%splits string into delimiters and returns a cellstr array
str=char(str); %in case a cell
lenstr=length(str);
delims=findstr(str,delim);
if isempty(delims), cells=cellstr(str); return; end
delims=[0 delims lenstr+1];
numstrs=length(delims)-1;
cells=cell(numstrs,1);
for i=1:numstrs,
   cells{i}=str(delims(i)+1:delims(i+1)-1);
end


