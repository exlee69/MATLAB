%% Extract DJIA components
WebsiteOfHistoricalComponents = 'https://en.wikipedia.org/wiki/Historical_components_of_the_Dow_Jones_Industrial_Average';
fullList = webread(WebsiteOfHistoricalComponents);

%% Filter companies
str1 = regexprep(fullList,'[\n\r]+',' ');
myRegExp = '(?<=<td>).+?(?=</td>)'; 
filteredData = regexp(str1,myRegExp,'match');
filteredData = filteredData.';                   %transpose
%% Filter dates
myregexp = '(?<="></span><span class="mw-headline" id=").+?(?=">)'; 
dates = regexp(str1,myregexp,'match');  %Filter dates
dates = regexprep(dates,'_',' ');       %Remove underscores
dates = dates.'                         %Transpose

%% Split cells by mm, dd, yyy
datesplit = regexp(dates, '\W+', 'split')  % split into columns
datesplit = vertcat(datesplit{:})             % display all on 1 sheet

%% Change to datetime (change to 3-letter month)
months = datesplit(:,1)     % extract all months
t = char(months)            % change to string
t = cellstr(t(:,1:3))       % extract first 3 alphabets and return to cells
datesplit(:,1) = t(:,1)

datefmt = datetime(dates,'InputFormat','dd-MMM-yyyy HH:mm:ss')

%% Change to datetime (change months and dates into mm,dd) 

% Change to date string - mm/dd/yyyy
