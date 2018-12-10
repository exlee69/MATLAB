% set working directory

% set parameter


%% extract DJIA components from 2004 onwards
WebsiteOfHistoricalComponents = 'https://en.wikipedia.org/wiki/Historical_components_of_the_Dow_Jones_Industrial_Average';
fullList = webread(WebsiteOfHistoricalComponents);
fullList = extractBefore(fullList,'<p>AT&amp;T, Eastman Kodak, and International Paper were replaced by American International, Pfizer, and Verizon.');

%% obtain list of companies which are/ used to be a DJIA component

companies = GetDJIAComponents(fullList);

%% extract dates in which DJIA historical components changes & the previous trading day before the next date when the component changes
[DJIAComponentChangeDate, DatePrevious] = DJIADateComponentChange(fullList)

%% Compile dates and companies into one sheet
compiled = cellstr(DJIAComponentChangeDate);
compiled(:,2) = DatePrevious
compiled(:,3:32) = companies(:,:)
 %reverse dates from earliest to latest
compiled = flipud(compiled);                    

%% find associated tickers with list of companies
% get universe of companies with tickers (get data from
% http://eoddata.com/symbols.aspx)
NASDAQ = readtable('NASDAQ.txt');
NYSE= readtable('NYSE.txt');
TickerUniverse = Ticker(NYSE,NASDAQ);

%% standardise company names to TickerUniverse & convert companies in compiled dataset to its tickers
[StandardisedCompanyName,CompiledTickers] = TickerConversion(compiled, TickerUniverse);


%% Creation of Mega Dataset for dates, closing prices of DJIA components, DJIA index, and Special Divisor
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



%% plot time series divider WIP
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






