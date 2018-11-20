% function [stock_symbol_list] = get_stock_symbols(index,sector)
%
% Description: This function gets the list of symbols for
% stocks from indices or sectors, as defined by the user.
%
% Usage:   [stock_symbol_list] = get_stock_symbols(index,sector);
%
% Input:
%                    index  = choose from 'NASDAQ','NYSE','AMEX','LSE' or 'OTCBB'
%                    sector = choose from an industry sector (from
%                             all indices above). Sector can be number or name.
%                    'list' = choose get_stock_symbols('list') for a list of sectors and sector numbers
%
% History:  29-Sep-09: Created by Alejandro Arrizabalaga (Matlab 2008a version)
%           07-Oct-09: Added possibility to get symbols from sectors.

function [stock_symbol_list] = get_stock_symbols(varargin)

% defaults
doindex=0;
dosector=0;
letters=cellstr(['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z']');

% process arguments
iarg = 0;
while (iarg<nargin)
    iarg = iarg +1;
    if (isstr(varargin{iarg}))
        if any(strcmp(varargin{iarg},{'NASDAQ' 'NYSE' 'AMEX' 'LSE' 'OTCBB'}))
            index = cellstr(varargin{iarg});
            doindex = 1;
        elseif strcmp(varargin{iarg},'list');
            try
                sector_list = get_sector_list;
                stock_symbol_list = sector_list;
            catch
                error('Unable to retrieve sector list from the Yahoo Finance site.');
            end
        else %check if it's a sector
            try
                sector_list = lower(get_sector_list);
            catch
                error('Unable to retrieve sector list from the Yahoo Finance site.');
            end
            sector_id=find(ismember(sector_list, lower(varargin{iarg}))==1);
            if ~isempty(sector_id)
                dosector=1;
                sector_number_string=char(sector_list(sector_id));
                sector_number=str2num(sector_number_string);
                if isempty(sector_number)
                    sector_number_string=char(sector_list(floor(sector_id-length(sector_list))));
                    sector_number=str2num(sector_number_string);
                end
            else
                error('Invalid option');
            end
        end
    else
        error('Invalid option');
    end
end
  
if doindex
    symbol_letters=[];
        for i=1:length(letters)
            eoddata_symbol_page=urlread(['http://www.eoddata.com/Stocklist/' char(index) '/' letters{i} '.htm']);
            symbol_string_begin=['title="Display Quote &amp; Chart for ' char(index) ','];
            symbol_string_end='</A></td><td>';
            symbol_ids_begin=strfind(eoddata_symbol_page,symbol_string_begin)+length(symbol_string_begin);
            symbol_ids_end=strfind(eoddata_symbol_page,symbol_string_end)-1;
            symbols_thisletter={[]};
            for i=1:length(symbol_ids_begin)
                stringy=eoddata_symbol_page(symbol_ids_begin(i):symbol_ids_end(i));
                stringy=regexprep(stringy,'">','');
                stringy=stringy(1:floor(length(stringy)/2));
                %if OTCBB then add .OB to symbol
                if strcmp(index,'OTCBB');stringy=[stringy '.OB'];end
                symbols_thisletter(i,:)=cellstr(stringy);
            end
            symbol_letters=[symbol_letters;symbols_thisletter];
        end
    index_symbols=symbol_letters;
end

if dosector
    %Get list of symbols for that sector
    sector_page=['http://biz.yahoo.com/p/' sector_number_string 'conameu.html'];
    sector_page_read=urlread(sector_page);
    begin_symbols=strfind(sector_page_read,'d=t">');
    end_symbols=strfind(sector_page_read,'</a>)</font></td><td');
    begin_end_symbols=[begin_symbols'+5 end_symbols'-1];

    sector_symbols={[]};
    for i=1:length(begin_end_symbols)
        stringy=sector_page_read(begin_end_symbols(i,1):begin_end_symbols(i,2));
        sector_symbols(i,:)=cellstr(stringy);
    end
end

if dosector & doindex
    overlapping_symbol_indices=find(ismember(sector_symbols,index_symbols)==1);
    stock_symbol_list=sector_symbols(overlapping_symbol_indices);
else
    if dosector
        stock_symbol_list=sector_symbols;
    elseif doindex
        stock_symbol_list=index_symbols;
    end
end


%%% OTHER FUNCTIONS

% function [stock_symbol_list] = get_sector_list
%
% Description: This function gets the list of numbers for the various
% stock sectors.
%
% Usage:   [stock_symbol_list] = get_sector_list;
%
%
% History:  05-Oct-09: Created by Alejandro Arrizabalaga (Matlab 2008a version)
function [stock_symbol_list] = get_sector_list

yahoo_page='http://biz.yahoo.com/ic/ind_index.html';
yahoo=urlread(yahoo_page);

begin_titles=strfind(yahoo,['colspan=2><font']);
end_titles=strfind(yahoo,'</b></font></td></tr><tr><td');
begin_end_titles=[begin_titles'+30 end_titles'-1];

begin_symbols_str='href="http://us.rd.yahoo.com/finance/industry/industryindex/';
begin_symbols=strfind(yahoo,begin_symbols_str);
begin_end_symbols=[[begin_symbols+length(begin_symbols_str)]' [begin_symbols+length(begin_symbols_str)+2]'];

begin_symbols_name=begin_symbols+length(begin_symbols_str)+length('122/*http://biz.yahoo.com/ic/122.html');
end_symbols_name=strfind(yahoo,'</a></font></td></tr><tr><td');
end_symbols_name(1)=[]; %remove the Title of the page
end_symbols_name_plus=strfind(yahoo,'</a></font></td></tr></table>');
begin_end_symbols_name=[[begin_symbols_name]'+2 sort([end_symbols_name';end_symbols_name_plus']-1)];

begin_end_all=sortrows([[begin_end_titles ones(length(begin_end_titles),1)+1];[begin_end_symbols zeros(length(begin_end_symbols),1)];[begin_end_symbols_name ones(length(begin_end_symbols_name),1)]]);
begin_end_codes=sortrows([[begin_end_symbols zeros(length(begin_end_symbols),1)];[begin_end_symbols_name ones(length(begin_end_symbols_name),1)]]);

stock_symbol_list={[]};
for i=1:length(begin_end_symbols)
    stringy=yahoo(begin_end_symbols(i,1):begin_end_symbols(i,2));
    stock_symbol_list(i,1)=cellstr(stringy);
end
for i=1:length(begin_end_symbols_name)
    stringy=strrep(yahoo(begin_end_symbols_name(i,1):begin_end_symbols_name(i,2)),char(10),' ');
    stringy=strrep(stringy,char(13),' ');
    stringy=strrep(stringy,'amp;','');
    stock_symbol_list(i,2)=cellstr(stringy);
end