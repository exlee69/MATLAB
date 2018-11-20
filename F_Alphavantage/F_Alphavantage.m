function [F_AV, Info, Unadjusted] = F_Alphavantage(Query, varargin)
%F_A_V fetches specified data series from Alphavantage
%   Only single queries are input
%   Possible queries are available at https://www.alphavantage.co/documentation/
    
%   Query must be char string (not case sensitive)
%       If 5-char string ends in 'X' then mutual fund will be queried first
%   Subsequent inputs must be query field (char string) followed by parameter
%       '1min', '5min', '15min', '30min', '60min', 'daily', 'weekly', 'monthly' will be detected for 'interval' field
%       'close', 'open', 'high', 'low' will be detected for 'series_type' field
%       'compact', 'full' will be detected for 'outputsize' field
%       Numerical parameters will be converted to char string
    
%   F_AV outputs table with datetime and data series
%   Info (optional) outputs struct with misc data for Tickers queried
%   Unadjusted (optional) outputs table with same datetime series but unadjusted prices
%       Dividend cash per share and split factor are found in Unadjusted

Key = 'ENTER ACTUAL KEY CODE HERE AFTER REGISTERING AT ALPHAVANTAGE.CO';
%% Validate inputs
%Check Query
if ~ischar(Query)
    warning('##### Query must be single char string');
end
Query = ['https://www.alphavantage.co/query?function=', upper(Query)]; %Standardise to uppercase

if nargin > 1
    Num_Parameter = numel(varargin);
else
    Num_Parameter = 0; %Valid for 'SECTOR' function query
end

warning('off', 'MATLAB:table:ModifiedVarnames');

%% Obtain raw data through Alphavantage
for Dot_Parameter = 1 : Num_Parameter
    switch lower(varargin{Dot_Parameter})
        case {'time_period', 'fastlimit', 'slowlimit', 'fastperiod', 'slowperiod', 'signalperiod', 'fastmatype', 'slowmatype', 'signalmatype', 'fastkperiod', 'fastdperiod', 'fastdmatype', 'slowkperiod', 'slowdperiod', 'slowkmatype', 'slowdmatype', 'matype', 'timeperiod1', 'timeperiod2', 'timeperiod3', 'nbdevup', 'nbdevdn', 'acceleration', 'maximum'}
            if Num_Parameter > Dot_Parameter %Subsequent input presumed to be specifier
                Specifier = varargin{Dot_Parameter + 1};
                if isnumeric(Specifier) %Change to string if input as numeric
                    Specifier = char(Specifier);
                end
                Query = [Query, '&', lower(varargin{Dot_Parameter}), '=', Specifier];
            else
                warning(['##### Expected specifier not found after ', varargin{Dot_Parameter}]);
            end
            varargin{Dot_Parameter + 1} = ''; %Void specifier to bypass next loop
        case {'symbol', 'interval', 'outputsize', 'series_type'}
            if Num_Parameter > Dot_Parameter %Subsequent input presumed to be specifier
                Query = [Query, '&', lower(varargin{Dot_Parameter}), '=', varargin{Dot_Parameter + 1}];
            else
                warning(['##### Expected specifier not found after ', varargin{Dot_Parameter}]);
            end
            varargin{Dot_Parameter + 1} = ''; %Void specifier to bypass next loop
        case {'from_currency', 'to_currency', 'market'} %Convention specifies uppercase
            if Num_Parameter > Dot_Parameter %Subsequent input presumed to be specifier
                Query = [Query, '&', lower(varargin{Dot_Parameter}), '=', upper(varargin{Dot_Parameter + 1})];
            else
                warning(['##### Expected specifier not found after ', varargin{Dot_Parameter}]);
            end
            varargin{Dot_Parameter + 1} = ''; %Void specifier to bypass next loop
        case {'1min', '5min', '15min', '30min', '60min', 'daily', 'weekly', 'monthly'}
            Query = [Query, '&interval=', lower(varargin{Dot_Parameter})];
        case {'compact', 'full'}
            Query = [Query, '&outputsize=', lower(varargin{Dot_Parameter})];
        case {'close', 'open', 'high', 'low'}
            Query = [Query, '&series_type=', lower(varargin{Dot_Parameter})];
        case ''
%           Take no action
        otherwise
            warning(['!!!!! Unknown input ', varargin{Dot_Parameter}]);
    end
end

Certificate_Bypass = weboptions('CertificateFilename', '', 'Timeout', 60); %Bypass security error for self-signed certificate

if ~isempty(strfind(Query, 'TIME_')) || ~isempty(strfind(Query, 'DIGITAL_CURRENCY'))
    Query = [Query, '&apikey=', Key, '&datatype=csv']; %CSV available
    Data_Not_Fetched = true;
    Tries = 1;
    while Data_Not_Fetched
        try
            Tries = Tries + 1;
            websave('AV_Temp.csv', Query, Certificate_Bypass);
            Raw_Table = readtable('AV_Temp.csv');
            Data_Not_Fetched = false; %Will not reach this step if fetch error
        catch
            Data_Not_Fetched = true & Tries <= 5; %Allow 5 attempts to fetch
            warning(['!!!!! Attempt ', num2str(Tries), ' unsuccessful for ', Query]);
            pause(15);
        end
    end
    
    try
        if ~issorted(Raw_Table.timestamp) %Confirm last known convention displaying in descending rather than ascending order
            Raw_Table = flipud(Raw_Table);
        end
    catch %Presumably after all tries exhausted, Raw_Table not successfully queried
        warning(['##### ', Query, ' not queried']);
        [F_AV, Info, Unadjusted] = deal(table);
        return
    end
    
    if     ~isempty(strfind(Query, '_ADJUSTED'))
        if ~isequal(Raw_Table.Properties.VariableNames, {'timestamp', 'open', 'high', 'low', 'close', 'adjusted_close', 'volume', 'dividend_amount', 'split_coefficient'})
            disp('##### CSV table from Alphavantage does not have expected column headers');
        end
        Raw_Table.Properties.VariableNames = {'Date', 'Open_Un', 'High_Un', 'Low_Un', 'Close_Un', 'Close', 'Volume_Un', 'Dividend', 'Split_Factor'};
        Raw_Table.Date = datetime(Raw_Table.Date, 'Format', 'yyyy MMM dd eee');
        
        Unadjusted = Raw_Table(:, [1 : 5, 7 : 9]);
        Unadjusted.Split_Factor = Raw_Table.Close ./ Raw_Table.Close_Un; %Replace with running factor that also accounts for dividends

        F_AV        = Raw_Table(:, 1); %Initialise with Date column
        F_AV.Open   = Raw_Table.Open_Un   .* Unadjusted.Split_Factor;
        F_AV.High   = Raw_Table.High_Un   .* Unadjusted.Split_Factor;
        F_AV.Low    = Raw_Table.Low_Un    .* Unadjusted.Split_Factor;
        F_AV.Close  = Raw_Table.Close;
        F_AV.Volume = Raw_Table.Volume_Un .* Unadjusted.Split_Factor;
    elseif ~isempty(strfind(Query, 'TIME_')) %Any other TIME_SERIES not adjusted
        if ~isequal(Raw_Table.Properties.VariableNames, {'timestamp', 'open', 'high', 'low', 'close', 'volume'})
            disp('##### CSV table from Alphavantage does not have expected column headers');
        end
        Raw_Table.Properties.VariableNames = {'Date', 'Open', 'High', 'Low', 'Close', 'Volume'};
        if ~isempty(strfind(Query, 'INTRADAY'))
            Raw_Table.Date = datetime(Raw_Table.Date, 'Format', 'yyyy MMM dd HH:mm eee');
        else
            Raw_Table.Date = datetime(Raw_Table.Date, 'Format', 'yyyy MMM dd eee'); %Omit minute data
        end
        
        [F_AV, Unadjusted] = deal(Raw_Table); %Both output tables are identical
    else %Already tested for other condition ('DIGITAL_CURRENCY')
        if ~isequal(Raw_Table.Properties.VariableNames([1, end - 1, end]), {'timestamp', 'volume', 'marketCap_USD_'})
            disp('##### CSV table from Alphavantage does not have expected column headers');
        end
        Raw_Table.Properties.VariableNames = regexprep(Raw_Table.Properties.VariableNames, '(\<\w)', '${upper($1)}'); %Cap first letter or each column variable
        Raw_Table.Properties.VariableNames{1} = 'Date';
        Raw_Table.Properties.VariableNames = regexprep(Raw_Table.Properties.VariableNames, '\_$', ''); %Delete terminal '_'
        
        if isempty(strfind(Query, 'INTRADAY'))
            if ~isempty(strfind(Raw_Table.Properties.VariableNames{2}, 'USD')) %USD is market currency
                Raw_Table = Raw_Table(:, [1 : 5, 10, 11]); %Delete duplicate USD columns
            end
            Raw_Table.Date = datetime(Raw_Table.Date, 'Format', 'yyyy MMM dd eee');
        else
            if ~isempty(strfind(Raw_Table.Properties.VariableNames{2}, 'USD')) %USD is market currency
                Raw_Table = Raw_Table(:, [1, 2, 4, 5]); %Delete duplicate USD column (#3)
            end
            Raw_Table.Date = datetime(Raw_Table.Date, 'Format', 'yyyy MMM dd HH:mm eee'); %No second-level increments
        end
        
        F_AV = Raw_Table;
        Unadjusted = table;
    end
    
    Info = table; %No info from CSV query
else
    Query = [Query, '&apikey=', Key]; %Must use JSON
    Raw_Table = webread(Query, Certificate_Bypass);

    if isstruct(Raw_Table)
        if     ~isempty(strfind(Query, 'CURRENCY_')) %Already filtered out digital currencies, which use CSV
            F_AV = struct2table(Raw_Table.RealtimeCurrencyExchangeRate);
            if ~isequal(F_AV.Properties.VariableNames, {'x1_From_CurrencyCode', 'x2_From_CurrencyName', 'x3_To_CurrencyCode', 'x4_To_CurrencyName', 'x5_ExchangeRate', 'x6_LastRefreshed', 'x7_TimeZone'})
                disp('##### JSON table from Alphavantage does not have expected column headers');
            end
            F_AV.Properties.VariableNames = {'Base_Curr', 'Base_Name', 'Quote_Curr', 'Quote_Name', 'Rate', 'Date', 'Time_Zone'};
            F_AV = F_AV(:, [6, 5, 1 : 4, 7]);
            F_AV.Date = datetime(F_AV.Date, 'Format', 'yyyy MMM dd HH:mm:ss eee'); %Snapshot time requires seconds
            
            [Info, Unadjusted] = deal(table); %Set empty for currency snapshot
        elseif ~isempty(strfind(Query, 'SECTOR'))
            Info = struct2table(Raw_Table.MetaData);
            Raw_Table = rmfield(Raw_Table, 'MetaData');
            
            Unadjusted = structfun(@Struct_Vert_Table, Raw_Table, 'UniformOutput', false);
            
            Rank_Fields = fieldnames(Unadjusted)';
            Rank_Tables = struct2cell(Unadjusted);
            for Dot_Rank = 1 : numel(Rank_Tables)
                Rank_Tables{Dot_Rank}.Properties.VariableNames{2} = Rank_Fields{Dot_Rank};
                if Dot_Rank == 1
                    F_AV = Rank_Tables{1}; %Initialise as first table
                else
                    F_AV = outerjoin(F_AV, Rank_Tables{Dot_Rank}, 'MergeKeys', true); %Retains any sectors (i. e., real estate) not present in all time periods
                end
            end
        else
            Info = struct2table(Raw_Table.MetaData);
            Info.Properties.VariableNames = regexprep(Info.Properties.VariableNames, 'x\d*_\d*_', ''); %Remove initial x#_#_ (first, to avoid disallowed initial number)
            Info.Properties.VariableNames = regexprep(Info.Properties.VariableNames, 'x\d*_',     ''); %Remove initial x#_
            
            Raw_Table = struct2table(Raw_Table);
            Raw_Table = Raw_Table{1, 2};
            
            Unadjusted = struct2array(Raw_Table); %Actually converts to vertical struct with indicator values as text
            Unadjusted = struct2table(Unadjusted); %Single column table with values in char string format
            
            F_AV = fieldnames(Raw_Table);
            F_AV = regexprep (F_AV, 'x', '');
            F_AV = regexprep (F_AV, '_', '-');
            if ~isempty(regexpi(Query, '\d*min')) %Intraday (minute) interval specified
                F_AV = datetime(F_AV, 'InputFormat', 'yyyy-MM-ddHH-mm', 'Format', 'yyyy MMM dd eee HH:mm');
            else %No minute-level time data
                F_AV = datetime(F_AV, 'ConvertFrom', 'datestr', 'Format', 'yyyy MMM dd eee');
            end
            if ~issorted(F_AV) %Confirm last known convention displaying in descending rather than ascending order
                F_AV = flipud(F_AV);
            end
            F_AV = table     (F_AV);
            
            F_AV = [F_AV, array2table(str2double(Unadjusted{:, 1 : end}))]; %Add corresponding numeric values to date column
            F_AV.Properties.VariableNames = [{'Date'}, Unadjusted.Properties.VariableNames]; %Attach column names
        end
    else
        warning('!!!!! Raw output is not in expected struct format');
    end
end

if ~istable(F_AV)
    warning('##### Resulting output is not in expected table format');
end
%{
if any(strcmpi(F_AV.Properties.VariableNames), 'Date') %Only check if output table has date column
    if floor(datenum(F_AV.Date(end))) < today
        warning('!!!!! Latest bar is dated earlier than today');
    end
end
%}
    function S_VT = Struct_Vert_Table(Struct_Input)
        S_VT = fieldnames(Struct_Input);
        Percentages = struct2cell(Struct_Input);
        Percentages = regexprep(Percentages, '%', ''); %Remove '%' prior to converting to number
        S_VT = table(S_VT, Percentages, 'VariableNames', {'Sector', 'Performance'});
        S_VT.Performance = str2double(S_VT.Performance) / 100; %Complete conversion to numeric
    end
end