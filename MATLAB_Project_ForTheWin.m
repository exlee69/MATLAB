
% relevant data inputs for the model
StartDate = '29011985' %yahoofinance is fixed at this date
EndDate = '15042008'
% Download time series of DJIA index value from YahooFinance
DJIAdata = hist_stock_data(StartDate,EndDate,'^DJI')



% Build table data for DJIA closing price
DJIADates = DJIAdata.Date
DJIAClosingPrice = DJIAdata.Close
DJIAPriceData = table(DJIADates,DJIAClosingPrice)
DJIAPriceData(:,'DJIADates') 
DJIAPriceData(:,'DJIAClosingPrice') 
DJIAPriceData(1,1)
DJIAPriceData(1,2)



% extract DJIA components from 1998 onwards (due to alphavantage)
WebsiteOfHistoricalComponents = 'https://en.wikipedia.org/wiki/Historical_components_of_the_Dow_Jones_Industrial_Average';
fullList = webread(WebsiteOfHistoricalComponents)
fullList = extractBefore(fullList,'<p>Chevron, Goodyear, Sears Roebuck, and Union Carbide were replaced by Home Depot, Intel, Microsoft, and SBC Communications. Travelers and Citicorp merge under the name Citigroup.')
% obtain list of companies which are/ used to be a DJIA component
% cleaning data
% extract DJIA historical components
% replace new line with white space in text documents
str1 = regexprep(fullList,'[\n\r]+',' ')
myRegExp = '(?<=<td>).+?(?=</td>)'; 
filteredData = regexp(str1,myRegExp,'match')
filteredData = filteredData.'
% remove those elements not related to companies
% remove (Preferred)
filteredDatav2 = regexprep(filteredData,'(\S)Preferred(\S)','')
% remove (First Preferred)
filteredDatav2 = regexprep(filteredDatav2,'(\S)First Preferred(\S)','')
% remove (B shares)
filteredDatav2 = regexprep(filteredDatav2,'(\S)B shares[\s\w]*(\S)','')
%remove amp;
filteredDatav2 = regexprep(filteredDatav2,'amp;','')
%remove ?, ?,  ?
filteredDatav2 = regexprep(filteredDatav2,'[???]','')
%remove <br/>[\s\w./=]</span>
filteredDatav2 = regexprep(filteredDatav2,'<br /><[\S\s]+>[\S\s]*</span>','')
%remove <sup id...>\S</sup>
filteredDatav2 = regexprep(filteredDatav2,'<[sup id].+?>[\S]+</sup>','')
% remove hyperlink from words (unable to remove hyperlink without removing
% the words directly
filteredDatav2 = regexprep(filteredDatav2,'<.*?>','')
% remove unwanted companies who drop out from the DJIA
filteredDatav3 = strtrim(filteredDatav2)
filteredDatav3 = filteredDatav3(~cellfun('isempty', filteredDatav3))
filteredDatav3 = regexprep(filteredDatav3,'\.','')
filteredDatav4 = {}
n = length(filteredDatav3)
for c = 1:length(filteredDatav3)
    testelement = char(filteredDatav3(c,1))
    d = testelement(end)
    filteredDatav4{end+1} = d
end
filteredDatav4 = filteredDatav4.'
for c = 1:length(filteredDatav3)
    test = sum(char(filteredDatav4(c,1)))
    if test == 8595
        filteredDatav3(c,1) = cellstr("")
    end
end
filteredDatav3 = filteredDatav3(~cellfun('isempty', filteredDatav3))
companies = reshape(filteredDatav3,30,[])
companies = companies.'
% remove unwanted symbols
companies = pad(companies,40,'right')
companies = regexprep(companies,'\s\W\s{5,29}','')
companies = strtrim(companies)



% extract dates in which DJIA historical components changes
myregexp = '(?<="></span><span class="mw-headline" id=").+?(?=">)';
dates = regexp(str1,myregexp,'match');
dates = regexprep(dates,'_',' ');
%transpose
dates = dates.'
% Split cells by mm, dd, yyy
datesplit = regexp(dates, '\W+', 'split')  % split into columns
datesplit = vertcat(datesplit{:}) 
% train of thought
% step 1: split the date split vector into 3 column vectors
datesplit_month = datesplit(:,1)
datesplit_day = datesplit(:,2)
datesplit_year = datesplit(:,3)
% convert date_split to string
datesplit_day_string = string(datesplit_day)
% standardise datesplit_day_string to all 2 digits
datesplit_day_string_standardise = pad(b,2,'left','0')
% step 2: rearrange the column vector by combining the 3 separate column
% vectors and inserting hyphens in between the string
combined_date = strcat(datesplit_year,"-",datesplit_month,"-",datesplit_day_string_standardise)
% step 3: convert to date-time format
% Just to help MATLAB recognise the format in 
datestring = datestr(combined_date,24)           
% Convert to ddmmyyyy
datestring = datestr(combined_date,'ddmmyyy')    

% Compile dates and companies into one sheet
compiled = cellstr(datestring)
compiled(:,2:31) = companies(:,:)


% brian add your part here

% Download times series of DJIA components from Alpha Vantage
% Your API key is: K2RGDAOSJL3AA6O5
MSFT = F_Alphavantage('TIME_SERIES_DAILY','symbol','MSFT','outputsize','full') 
MSFTDate = MSFT.Date
MSFTClosingPrice = MSFT.Close
MSFTData = table(MSFTDate,MSFTClosingPrice)

-------------------------------------------
% WIP
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
    
    end   
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


