

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



% extract DJIA components
WebsiteOfHistoricalComponents = 'https://en.wikipedia.org/wiki/Historical_components_of_the_Dow_Jones_Industrial_Average';
fullList = webread(WebsiteOfHistoricalComponents)
% obtain list of companies which are/ used to be a DJIA component
% cleaning data
% replace new line with white space in text documents
str1 = regexprep(fullList,'[\n\r]+',' ')
myRegExp = '(?<=<td>).+?(?=</td>)'; 
filteredData = regexp(str1,myRegExp,'match')
%transpose
filteredData = filteredData.'
%for loop to remove components that are not company names
for i = 1:length(filteredData)
    if DJIADates(i,1)
end

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