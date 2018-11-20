
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
% remove unwanted symbols behind the company names
filteredDatav2 = erase(filteredDatav2," ? ")
filteredDatav2 = erase(filteredDatav2," ? ")
filteredDatav2 = erase(filteredDatav2," ?  ")
filteredDatav2 = erase(filteredDatav2," ?  ")
filteredDatav2 = erase(filteredDatav2," ?  ")
filteredDatav2 = strtrim(filteredDatav2)
filteredDatav2 = erase(filteredDatav2,"?")
filteredDatav2 = erase(filteredDatav2,' sup id="cite_ref-2" class="reference">&#91;2&#93;)')
% remove repeated dataset
filteredDatav2 = unique(filteredDatav2)
% remove blank cell before 3M company
filteredDatav2(1,:) = []
% remove
 

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



% Download times series of DJIA components from Alpha Vantage
% Your API key is: K2RGDAOSJL3AA6O5
MSFT = F_Alphavantage('TIME_SERIES_DAILY','symbol','MSFT','outputsize','full') 
MSFTDate = MSFT.Date
MSFTClosingPrice = MSFT.Close
MSFTData = table(MSFTDate,MSFTClosingPrice)
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
