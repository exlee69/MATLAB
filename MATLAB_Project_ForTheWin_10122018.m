% set working directory

% initialise paramaters/ set constants

% functions


% extract DJIA components from 1998 onwards (due to alphavantage)
WebsiteOfHistoricalComponents = 'https://en.wikipedia.org/wiki/Historical_components_of_the_Dow_Jones_Industrial_Average';
fullList = webread(WebsiteOfHistoricalComponents);
fullList = extractBefore(fullList,'<p>SBC Communications Inc. was renamed AT&amp;T Inc.');
% obtain list of companies which are/ used to be a DJIA component
% cleaning data
% extract DJIA historical components
% replace new line with white space in text documents
str1 = regexprep(fullList,'[\n\r]+',' ');
myRegExp = '(?<=<td>).+?(?=</td>)'; 
filteredData = regexp(str1,myRegExp,'match');
filteredData = filteredData.'
% remove those elements not related to companies
%remove amp;
filteredData = regexprep(filteredData,'amp;','');
%remove ?, ?,  ?
filteredData = regexprep(filteredData,'[???]','');
%remove <br/>[\s\w./=]</span>
filteredData = regexprep(filteredData,'<br /><[\S\s]+>[\S\s]*</span>','');
%remove <sup id...>\S</sup>
filteredData = regexprep(filteredData,'<[sup id].+?>[\S]+</sup>','');
% remove hyperlink from words (unable to remove hyperlink without removing
% the words directly
filteredData = regexprep(filteredData,'<.*?>','');
% remove unwanted companies who drop out from the DJIA
filteredData = strtrim(filteredData);
filteredData = filteredData(~cellfun('isempty', filteredData));
filteredData = regexprep(filteredData,'\.','');
filteredDatav2 = {};
for c = 1:length(filteredData)
    testelement = char(filteredData(c,1));
    d = testelement(end);
    filteredDatav2{end+1} = d;
end
filteredDatav2 = filteredDatav2.';
for c = 1:length(filteredData)
    test = sum(char(filteredDatav2(c,1)));
    if test == 8595
        filteredData(c,1) = cellstr("");
    end
end
filteredData = filteredData(~cellfun('isempty', filteredData));
companies = reshape(filteredData,30,[]);
companies = companies.';
% remove unwanted symbols
% make this more flexible please
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
date_prev(2:11,1) = date_prev(1:10,1)
date_prev{1,1} = datestr(datetime('today'),'ddmmyyyy')
date_prev(11,:) = []


% Compile dates and companies into one sheet
compiled = cellstr(datestring);
compiled(:,2) = cellstr(date_prev)
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
TickerUniverse = table2cell(TickerUniverse);
% remove unnecessary data (JP Morgan)
TickerUniverse(3305,:)=[];
TickerUniverse(3298,:)=[];
TickerUniverse(198,:)=[];


% standardise company names to TickerUniverse
compiled = regexprep(compiled,'Corporation','Corp');
compiled = regexprep(compiled,'(\w\s)* & Co, Inc',' & Company');
compiled = regexprep(compiled,'Alcoa Inc','Alcoa Corp');
compiled = regexprep(compiled,'AlliedSignal Incorporated','Honeywell International Inc');
compiled = regexprep(compiled,'Altria Group Incorporated','Altria Group');
compiled = regexprep(compiled,'Altria Group, Incorporated','Altria Group');
compiled = regexprep(compiled,'American International Group Inc','American International Group');
compiled = regexprep(compiled,'AT&T Corp','AT&T Inc');
compiled = regexprep(compiled,'Cisco Systems, Inc','Cisco Systems Inc');
compiled = regexprep(compiled,'DowDuPont Inc','Dowdupont Inc');
compiled = regexprep(compiled,'Eastman Kodak Company','Eastman Kodak');
compiled = regexprep(compiled,'EI du Pont de Nemours & Company','Dowdupont Inc');
compiled = regexprep(compiled,'Exxon Corp','Exxon Mobil Corp');
compiled = regexprep(compiled,'General Motors Corp','General Motors Company');
compiled = regexprep(compiled,'Honeywell International','Honeywell International Inc');
compiled = regexprep(compiled,'Honeywell International Inc Inc','Honeywell International Inc');
compiled = regexprep(compiled,'Intel Corporation','Intel Corp');
compiled = regexprep(compiled,'International Business Machines Corp','International Business Machines');
compiled = regexprep(compiled,'Kraft Foods Inc','Mondelez Intl Cmn A');
compiled = regexprep(compiled,'Nike, Inc','Nike Inc');
compiled = regexprep(compiled,'JPMorgan Chase & Co','JP Morgan Chase & Co');
compiled = regexprep(compiled,'SBC Communications Inc','AT&T Inc');
compiled = regexprep(compiled,'The Boeing','Boeing');
compiled = regexprep(compiled,'The Coca','Coca');
compiled = regexprep(compiled,'The Goldman Sachs Group, Inc','Goldman Sachs Group');
compiled = regexprep(compiled,'The Home Depot, Inc','Home Depot');
compiled = regexprep(compiled,'The Procter','Procter');
compiled = regexprep(compiled,'The Travelers Companies, Inc','The Travelers Companies Inc');
compiled = regexprep(compiled,'The Walt','Walt');
compiled = regexprep(compiled,'UnitedHealth Group Inc','Unitedhealth Group Inc');
compiled = regexprep(compiled,'Verizon Communications, Inc','Verizon Communications Inc');
compiled = regexprep(compiled,'Wal-Mart Stores, Inc','Wal-Mart Stores');
compiled = regexprep(compiled,'Walmart Inc','Wal-Mart Stores');
compiled = regexprep(compiled,'Walgreens Boots Alliance, Inc','Walgreens Boots Alliance');
% MacDonalds
compiled(1:3,8) = compiled(4,5);

% convert companies in compiled dataset to its tickers
m = size(compiled);
n = length(compiled);
o = m(1,1);
compiledtickers = compiled;
for c = 1:o
    for b = 3:n
        a = find(strcmp(TickerUniverse(:,2), compiled(c,b)));
        compiledtickers(c,b) = TickerUniverse(a,1);
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
SizeOfCompiledData = size(compiledtickers);
n = SizeOfCompiledData(1,1);
m = SizeOfCompiledData(1,2);
CompanyData = zeros(1,31);
% Import GM Data (Dates and Closing Price)
GM = readtable('General motors stock prices.xlsx');
GMRelevantDate = GM.CombinedDate


for c= 1:n
    StartDateCompany = char(compiledtickers(c,1));
    EndDateCompany = char(compiledtickers(c,2));
    GetDates = hist_stock_data(StartDateCompany,EndDateCompany,'^DJI');
    MiniRelevantDates = GetDates.Date;
    MiniRelevantDates = length(MiniRelevantDates);
    MiniCompanyData = zeros(MiniRelevantDates,1);
    for d = 3:m
        CompanyNameStr = char(compiledtickers(c,d));
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
    StartDateCompany = char(compiledtickers(c,1));
    EndDateCompany = char(compiledtickers(c,2));
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

% plot DJIA & Sum of Company Prices with time
sum = MegaDataSet{:,32}
t = datetime(MegaDataSet{:,1})
yyaxis left
ylabel('Sum of Company Prices')
correlation = plot(t,sum,'LineWidth',0.4)

hold on

DJIA = MegaDataSet{:,33}
yyaxis right
ylabel('DJIA')
correlation = plot(t,DJIA,'LineWidth',0.4)

hold off

datetick('x','yyyy')
xlabel('Time')
ylabel('')
title('Correlation between Sum of Company Prices and DJIA')






