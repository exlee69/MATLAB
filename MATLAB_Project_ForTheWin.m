
% extract DJIA components from 1998 onwards (due to alphavantage)
WebsiteOfHistoricalComponents = 'https://en.wikipedia.org/wiki/Historical_components_of_the_Dow_Jones_Industrial_Average';
fullList = webread(WebsiteOfHistoricalComponents);
fullList = extractBefore(fullList,'<p>AT&amp;T, Eastman Kodak, and International Paper were replaced by American International, Pfizer, and Verizon.');
% obtain list of companies which are/ used to be a DJIA component
% cleaning data
% extract DJIA historical components
% replace new line with white space in text documents
str1 = regexprep(fullList,'[\n\r]+',' ');
myRegExp = '(?<=<td>).+?(?=</td>)'; 
filteredData = regexp(str1,myRegExp,'match');
filteredData = filteredData.';
% remove those elements not related to companies
%remove amp;
filteredDatav2 = regexprep(filteredData,'amp;','');
%remove ?, ?,  ?
filteredDatav2 = regexprep(filteredDatav2,'[???]','');
%remove <br/>[\s\w./=]</span>
filteredDatav2 = regexprep(filteredDatav2,'<br /><[\S\s]+>[\S\s]*</span>','');
%remove <sup id...>\S</sup>
filteredDatav2 = regexprep(filteredDatav2,'<[sup id].+?>[\S]+</sup>','');
% remove hyperlink from words (unable to remove hyperlink without removing
% the words directly
filteredDatav2 = regexprep(filteredDatav2,'<.*?>','');
% remove unwanted companies who drop out from the DJIA
filteredDatav3 = strtrim(filteredDatav2);
filteredDatav3 = filteredDatav3(~cellfun('isempty', filteredDatav3));
filteredDatav3 = regexprep(filteredDatav3,'\.','');
filteredDatav4 = {};
for c = 1:length(filteredDatav3)
    testelement = char(filteredDatav3(c,1));
    d = testelement(end);
    filteredDatav4{end+1} = d;
end
filteredDatav4 = filteredDatav4.';
for c = 1:length(filteredDatav3)
    test = sum(char(filteredDatav4(c,1)));
    if test == 8595
        filteredDatav3(c,1) = cellstr("");
    end
end
filteredDatav3 = filteredDatav3(~cellfun('isempty', filteredDatav3));
companies = reshape(filteredDatav3,30,[]);
companies = companies.';
% remove unwanted symbols
companies = pad(companies,40,'right');
companies = regexprep(companies,'\s\W\s{5,29}','');
companies = strtrim(companies);



% extract dates in which DJIA historical components changes
myregexp = '(?<="></span><span class="mw-headline" id=").+?(?=">)';
dates = regexp(str1,myregexp,'match');
dates = regexprep(dates,'_',' ');
%transpose
dates = dates.';
% Split cells by mm, dd, yyy
datesplit = regexp(dates, '\W+', 'split');  % split into columns
datesplit = vertcat(datesplit{:});
% train of thought
% step 1: split the date split vector into 3 column vectors
month = datesplit(:,1);
day = datesplit(:,2);
year = datesplit(:,3);
% convert date_split to string
day = string(day);
% standardise datesplit_day_string to all 2 digits
day_standardise = pad(day,2,'left','0');
% step 2: rearrange the column vector by combining the 3 separate column
% vectors and inserting hyphens in between the string
combined_date = strcat(day_standardise,"-",month,"-",year);
% step 3: convert to date-time format
% Just to help MATLAB recognise the datetime format
datestring = datestr(combined_date,24)           
% Convert to ddmmyyyy
datestring = datestr(combined_date,'ddmmyyyy')

% Get date of day before
date_prev = datetime(combined_date)
date_prev = dateshift(date_prev,'end','day','previous')
date_prev = datestr(date_prev,'ddmmyyyy')
date_prev = cellstr(date_prev)
today = datetime('today')
today = datestr(today,'ddmmyyyy')

% Compile dates and companies into one sheet
compiled = cellstr(datestring);
compiled(2:12,2) = cellstr(date_prev)
compiled{12,2} = []
compiled{1,2} = today
emptycells = cellfun(@isempty, compiled);       %find empty cells in the whole cell array
compiled(any(emptycells(:, [1 2]), 2), :) = []  %remove rows for which any of column 1 or 2 is empty
compiled(:,3:32) = companies(:,:)
compiled = flipud(compiled);                     %reverse dates from earliest to latest



% find associated tickers with list of companies
% get universe of companies with tickers (get data from
% http://eoddata.com/symbols.aspx)
NASDAQ = readtable('NASDAQ.txt');
NYSE= readtable('NYSE.txt');
TickerUniverse = [NASDAQ; NYSE];
% remove repeated datasets
TickerUniverse = unique(TickerUniverse);
TickerUniverse2 = table2cell(TickerUniverse);
% remove unnecessary data (JP Morgan)
TickerUniverse2(3305,:)=[];
TickerUniverse2(3298,:)=[];
TickerUniverse2(198,:)=[];


% standardise company names to TickerUniverse
compiledv2 = regexprep(compiled,'Corporation','Corp');
compiledv2 = regexprep(compiledv2,'(\w\s)* & Co, Inc',' & Company');
compiledv2 = regexprep(compiledv2,'Alcoa Inc','Alcoa Corp');
compiledv2 = regexprep(compiledv2,'AlliedSignal Incorporated','Honeywell International Inc');
compiledv2 = regexprep(compiledv2,'Altria Group Incorporated','Altria Group');
compiledv2 = regexprep(compiledv2,'Altria Group, Incorporated','Altria Group');
compiledv2 = regexprep(compiledv2,'American International Group Inc','American International Group');
compiledv2 = regexprep(compiledv2,'AT&T Corp','AT&T Inc');
compiledv2 = regexprep(compiledv2,'Cisco Systems, Inc','Cisco Systems Inc');
compiledv2 = regexprep(compiledv2,'DowDuPont Inc','Dowdupont Inc');
compiledv2 = regexprep(compiledv2,'Eastman Kodak Company','Eastman Kodak');
compiledv2 = regexprep(compiledv2,'EI du Pont de Nemours & Company','Dowdupont Inc');
compiledv2 = regexprep(compiledv2,'Exxon Corp','Exxon Mobil Corp');
compiledv2 = regexprep(compiledv2,'General Motors Corp','General Motors Company');
compiledv2 = regexprep(compiledv2,'Honeywell International','Honeywell International Inc');
compiledv2 = regexprep(compiledv2,'Honeywell International Inc Inc','Honeywell International Inc');
compiledv2 = regexprep(compiledv2,'Intel Corporation','Intel Corp');
compiledv2 = regexprep(compiledv2,'International Business Machines Corp','International Business Machines');
compiledv2 = regexprep(compiledv2,'Kraft Foods Inc','Mondelez Intl Cmn A');
compiledv2 = regexprep(compiledv2,'Nike, Inc','Nike Inc');
compiledv2 = regexprep(compiledv2,'JPMorgan Chase & Co','JP Morgan Chase & Co');
compiledv2 = regexprep(compiledv2,'SBC Communications Inc','AT&T Inc');
compiledv2 = regexprep(compiledv2,'The Boeing','Boeing');
compiledv2 = regexprep(compiledv2,'The Coca','Coca');
compiledv2 = regexprep(compiledv2,'The Goldman Sachs Group, Inc','Goldman Sachs Group');
compiledv2 = regexprep(compiledv2,'The Home Depot, Inc','Home Depot');
compiledv2 = regexprep(compiledv2,'The Procter','Procter');
compiledv2 = regexprep(compiledv2,'The Travelers Companies, Inc','The Travelers Companies Inc');
compiledv2 = regexprep(compiledv2,'The Walt','Walt');
compiledv2 = regexprep(compiledv2,'UnitedHealth Group Inc','Unitedhealth Group Inc');
compiledv2 = regexprep(compiledv2,'Verizon Communications, Inc','Verizon Communications Inc');
compiledv2 = regexprep(compiledv2,'Wal-Mart Stores, Inc','Wal-Mart Stores');
compiledv2 = regexprep(compiledv2,'Walmart Inc','Wal-Mart Stores');
compiledv2 = regexprep(compiledv2,'Walgreens Boots Alliance, Inc','Walgreens Boots Alliance');
% MacDonalds
compiledv2(1,5) = compiledv2(5,5);
compiledv2(2:4,8) = compiledv2(5,5);

% convert companies in compiledv2 dataset to its tickers
m = size(compiledv2);
n = length(compiledv2);
o = m(1,1);
compiledv3 = compiledv2;
for c = 1:o
    for b = 3:n
        a = find(strcmp(TickerUniverse2(:,2), compiledv2(c,b)));
        compiledv3(c,b) = TickerUniverse2(a,1);
    end
end


% relevant data inputs for the model
StartDate = '08042004'; %yahoofinance is fixed at this date
EndDate = datestr(now,'ddmmyyyy');

% Download time series of DJIA index value from YahooFinance
DJIAdata = hist_stock_data(StartDate,EndDate,'^DJI');
RelevantDates = DJIAdata.Date;
DJIAClosingPrice = DJIAdata.Close;
% Download time series of relevant companies from YahooFinance
SizeOfCompiledData = size(compiledv3);
n = SizeOfCompiledData(1,1);
m = SizeOfCompiledData(1,2);
CompanyData = zeros(1,31);
% Import GM Data (Dates and Closing Price)
GM = readtable('General motors stock prices.xlsx');
GMRelevantDate = GM.CombinedDate


for c= 1:n
    StartDateCompany = char(compiledv3(c,1));
    EndDateCompany = char(compiledv3(c,2));
    GetDates = hist_stock_data(StartDateCompany,EndDateCompany,'^DJI');
    MiniRelevantDates = GetDates.Date;
    MiniRelevantDates = length(MiniRelevantDates);
    MiniCompanyData = zeros(MiniRelevantDates,1);
    for d = 3:m
        CompanyNameStr = char(compiledv3(c,d));
        CompanyDataExtract = hist_stock_data(StartDateCompany,EndDateCompany,CompanyNameStr);
        if isempty(CompanyDataExtract)
            StartDateIndex = strmatch(StartDateCompany,GMRelevantDate);
            CompanyClosingPrice = table2array(GM(StartDateIndex:StartDateIndex+MiniRelevantDates-1,2));
            MiniCompanyData = [MiniCompanyData CompanyClosingPrice];
        else
            CompanyClosingPrice = CompanyDataExtract.Close;
            MiniCompanyData = [MiniCompanyData CompanyClosingPrice];
        end
    end
    CompanyData = [CompanyData; MiniCompanyData];
end
CompanyData(:,1) = [];
CompanyData(1,:) = [];




% check
h = [0]
for c= 1:11
    StartDateCompany = char(compiledv3(c,1));
    EndDateCompany = char(compiledv3(c,2));
    GetDates = hist_stock_data(StartDateCompany,EndDateCompany,'^DJI');
    MiniRelevantDates = GetDates.Date;
    h = [h;MiniRelevantDates];
end
h(1,:) = []
h1 = [h,RelevantDates] 
h1 = array2table(h1)
writetable(h1,"Check1.xls",'Sheet',1,'Range','A1')

% compute sum of companies, and include the Dates, DJIAClosingPrice into
% one big mega dataset
MegaDataSet = array2table(CompanyData);
RelevantDates = table(RelevantDates);
DJIAClosingPrice = table(DJIAClosingPrice);
SumOfCompanyPrices = sum(CompanyData,2);
SumOfCompanyPrices = array2table(SumOfCompanyPrices);
MegaDataSet = [RelevantDates,MegaDataSet,SumOfCompanyPrices,DJIAClosingPrice];
MegaDataSet.SpecialDivider = (MegaDataSet.SumOfCompanyPrices)./(MegaDataSet.DJIAClosingPrice);
% check
writetable(MegaDataSet,"Check2.xls",'Sheet',1,'Range','A1')



% plot time series divider WIP
x = datetime(MegaDataSet{:,1})
y = MegaDataSet{:,34}
TimeSeriesDivider = plot(x,y,'LineWidth',0.4,'Color',[0 0.5 0.5])
datetick('x','yyyy')
xlabel('Time')
ylabel('Special Divider')
title('Time Series Divider')






-------------------------------------------
% WIP

CompanyData = cell2table(CompanyData)
RelevantDate = table(DJIAdata.Date)
COMPILE = [RelevantDate,CompanyData]
% Download times series of DJIA components from Alpha Vantage
% Your API key is: K2RGDAOSJL3AA6O5

CompanyDate = table(CompanyDataExtract.Date)
CompanyData(:,1) = CompanyDate


% Build table data for DJIA closing price
DJIADates = DJIAdata.Date;
DJIAClosingPrice = DJIAdata.Close;
DJIAPriceData = table(DJIADates,DJIAClosingPrice);
DJIAPriceData(:,'DJIADates'); 
DJIAPriceData(:,'DJIAClosingPrice'); 
% for checking purpose
DJIAPriceData(1,1);
DJIAPriceData(1,2); 


companies2 = compiledv3(:,2:length(compiledv3))
companies2 = unique(reshape(companies2,[],1));
% Initialise array
Date = F_Alphavantage('TIME_SERIES_DAILY','symbol','AAPL','outputsize','full'); 
Date = Date.Date
CompanyData = zeros(length(Date),length(companies2))
length(companies2)
for c= 1:1
    CompanyNameStr = char(companies2(c,1));
    CompanyDataExtract = F_Alphavantage('TIME_SERIES_DAILY','symbol',CompanyNameStr,'outputsize','full'); 
    CompanyClosingPrice = table2array(table(CompanyDataExtract.Close));
    CompanyData(:,c) = CompanyClosingPrice;
end
CompanyDate = table(CompanyDataExtract.Date)
CompanyData(:,1) = CompanyDate



GM = F_Alphavantage('TIME_SERIES_DAILY','symbol','GM','outputsize','full') 
MSFTDate = MSFT.Date
MSFTClosingPrice = MSFT.Close
MSFTData = table(MSFTDate,MSFTClosingPrice);



-----------------------------------------------------
%Ignore
% Build Data Table for DJIA closing price
DJIADates = datenum(DJIAdata.Date)
DJIAClosingPrice = DJIAdata.Close
DJIAClose = DataTable()
DJIAClose{1,1:2} = {'Date', 'Closing Price'}
DJIAClose{2:length(DJIADates),:} = {DJIADates,DJIAClosingPrice}

% Build Data Frame for DJIA closing price (failed)
DJIADates = DJIAdata.Date
DJIAClosingPrice = DJIAdata.Close
DJIAPriceDataDataFrame = DataFrame(DJIADates, DJIAClosingPrice, ...
    'VariableNames', {'Date', 'ClosingPrice',}) [remove DataFrame]

%Build table for DJIA closing price
%convert cell type data to char type data
DJIADates = cell2mat(DJIAdata.Date)
DJIAClosingPrice = DJIAdata.Close
DJIAPriceDataFrame= {DJIADates,DJIAClosingPrice}
cell2mat(DJIADates)

% Build matrix data for DJIA closing price
DJIADates = datenum(DJIAdata.Date)
DJIADates = DJIAdata.Date
DJIAClosingPrice = DJIAdata.Close
DJIAPriceData = [DJIADates,DJIAClosingPrice]
DJIAPriceData = num2mat[DJIAPriceData]

% test
for i = 1:length(DJIADates)
    disp(DJIADates(i,1))
end


% initiate column names
ColNames = ('Dates' 'Closing Price')
DJIAPriceData(1,1:2) = ColNames
DJIAPriceDate= (DJIADates DJIAClosingPrice)

myRegExp = '(?<=<A HREF=).+?(?=>.+?</A>)';       % fill in here your regular expression

myText = ['It is <I>very</I> <B>important</B> to appreciate the <BR> role of <A HREF=www.wikipedia.org>regular expressions</A>. ' ...
'See <I>for example</I> <A HREF=www.xkcd.com>this webpage</A> and <A HREF=www.google.com>this page in general</A>.']
filteredData = regexp(myText,myRegExp,'match')

% replace new line with white space in text documents
str = regexprep(fullList,'\s+',' ')
list = regexprep(fullList,'<.*?>','')
subList = strsplit(list)

%for loop to remove components that are not company names
for i = 1:length(filteredData)
    if DJIADates(i,1)
    end
end
% remove specific unwanted substring from string cell
filteredDatav2 = erase(filteredDatav2,' sup id="cite_ref-2" class="reference">&#91;2&#93;)')
% add space after CAPS letter
regexprep('varNameOne', '([A-Z])', ' $1')

% remove unwanted characters
filteredDatav2 = regexprep(filteredDatav2,'\s\W\','')
filteredDatav2 = unique(filteredDatav2)
filteredDatav2 = regexprep(filteredDatav2, '([A-Z])', ' $1')

filteredDatav2 = strtrim(filteredDatav2)
filteredDatav2 = erase(filteredDatav2," ?")
filteredDatav2 = erase(filteredDatav2," ?")
filteredDatav2 = erase(filteredDatav2," ?")
filteredDatav2 = erase(filteredDatav2,"?")

% export data to excel
writetable(TickerUniverse, "TickerUniverse.xlsx")

filteredDatav3 = filteredDatav3(~cellfun('isempty', filteredDatav3))
    
    filteredDatav5{end+1} = d 
    filteredDatav5{end+1} = filteredDatav3(c,1) 

filteredDatav5 = string(filteredData




is_special = false(size(filteredDatav2))
is_special( regexp( filteredDatav2, '[^a-zA-Z0-9.&]' ) ) = true
TF = contains(filteredDatav2,'[^a-zA-Z0-9&]')

lastletter = filteredDatav2(end)





filteredDatav2 = unique(filteredDatav2)

filteredDatav2 = regexprep(filteredDatav2,'.*?(?=\W)','')



filteredDatav2 = pad(filteredDatav2,40,'right')
filteredDatav2 = regexprep(filteredDatav2,'\s\W\s{5,29}','')
filteredDatav2 = strtrim(filteredDatav2)
filteredDatav2 = unique(filteredDatav2)
filteredDatav2 = cellstr(filteredDatav2)
% remove blank cell before 3M company and unwanted companies
filteredDatav2(53,:) = []
filteredDatav2(45,:) = []
% Mac is an issue, 36 or 37
filteredDatav2(36,:) = []
filteredDatav2(28,:) = []
filteredDatav2(24,:) = []
filteredDatav2(1,:) = []
% convert cell array to table
filteredDatav3 = cell2table(filteredDatav2)
filteredDatav3.Properties.VariableNames = {'CompanyName'}

% find associated tickers with list of companies
% get universe of companies with tickers (delete get_stock_symbols)
NASDAQ = get_stock_symbols('NASDAQ')
NYSE = get_stock_symbols('NYSE')
AMEX = get_stock_symbols('AMEX')
% get data from http://eoddata.com/symbols.aspx
NASDAQ = readtable('NASDAQ.txt')
NYSE= readtable('NYSE.txt')
TickerUniverse = [NASDAQ; NYSE]
% remove repeated datasets
TickerUniverse = unique(TickerUniverse)
TickerUniverse2 = table2cell(TickerUniverse)
% for loop to append tickers into filteredDatav2 (STILL DOING)
for c = 1:length(filteredDatav2)
    if ~any(strcmp(TickerUniverse2(:,1),char(filteredDatav2(c,1))))
        % works only if filteredDatav2 is cell array
        Index = TickerUniverse(string(TickerUniverse.Description)== char(filteredDatav2(c,1)), :)
        % works
        filteredDatav3(c,2) = Index(1,1)
    end
end
% rename column name of filteredDatav3 to tickers
filteredDatav3.Properties.VariableNames = {'CompanyName' 'Ticker'}

% Download time series of relevant companies from YahooFinance
companies2 = compiledv3(:,2:length(compiledv3))
companies2 = unique(reshape(companies2,[],1));
CompanyData = zeros(height(table(DJIAdata.Date)),length(companies2))
length(companies2)
for c= 10:14
    CompanyNameStr = char(companies2(c,1));
    CompanyDataExtract = hist_stock_data(StartDate,EndDate,CompanyNameStr);
    CompanyClosingPrice = CompanyDataExtract.Close;
    CompanyData(:,c) = CompanyClosingPrice;
end



