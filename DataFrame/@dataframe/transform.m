function df=transform(df,varargin)
%DATAFRAME/transform
%transform(df,'var','trans'...)
% trans='log' w/ optional offset, assq, logit, none
% var may be 'clear' to clear all or 'all' to set same transform for all
% data
arg=1;
na=length(varargin);
if na==1 && strcmpi(varargin{1},'clear'),
    df.transform(:)=0;
    return;
end
while arg<=na,
    if arg==na, error('Invalid combination of transformation pairs input'); end
    if strcmp(varargin{arg},'all'),
        col=1:df.colct;
    else
        col=strmatch(varargin{arg},df.colnames);
    end
    if isempty(col), error(['Invalid column to transform: ' varargin{arg}]); end
    if df.types(col)~=1, error(['Can''t transform boolean/category data such as ' varargin{arg}]);end
    switch varargin{arg+1},
        case 'log',
            if arg+2<=na && isnumeric(varargin{arg+2}),
                df.transform(col)=-varargin{arg+2};
                arg=arg+1;
            else
                df.transform(col)=1;
            end
        case 'assq',
            df.transform(col)=2;
        case 'logit',
            df.transform(col)=3;
        case 'none',
            df.transform(col)=0;
        case 'clear',
            df.transform(col)=0;
    end
    arg=arg+2;
end
