%% Extract DJIA components
WebsiteOfHistoricalComponents = 'https://en.wikipedia.org/wiki/Historical_components_of_the_Dow_Jones_Industrial_Average';
fullList = webread(WebsiteOfHistoricalComponents);

%% Filter companies
str1 = regexprep(fullList,'[\n\r]+',' ');
myRegExp = '(?<=<td>).+?(?=</td>)'; 
filteredData = regexp(str1,myRegExp,'match');
filteredData = filteredData.'                               % transpose
filtered2 = regexprep(filteredData,'\W(Preferred)\W','')    % replace "(Preferred)"
filtered2 = regexprep(filtered2,'\W(amp)\W\s','')           % replace "&amp;"
filtered2 = regexprep(filtered2,'<.*?>','')                 % remove excess <html>

%% Filter dates
myregexp = '(?<="></span><span class="mw-headline" id=").+?(?=">)'; 
dates = regexp(str1,myregexp,'match');  %Filter dates
dates = regexprep(dates,'_',' ');       %Remove underscores
dates = dates.';                        %Transpose

%% Split cells by mm, dd, yyy
datesplit = regexp(dates, '\W+', 'split');  % split into columns
datesplit = vertcat(datesplit{:});             % display all on 1 sheet

%% Change to datetime (change to 3-letter month)
months = datesplit(:,1);     % extract all months
t = char(months);            % change to string
t = cellstr(t(:,1:3));       % extract first 3 alphabets and return to cells
datesplit(:,1) = t(:,1)

%% step 1: split the date split vector into 3 column vectors
month = datesplit(:,1)
day = datesplit(:,2)
year = datesplit(:,3)

% convert datesplit_day to string
day = string(day)
% standardise datesplit_day_string to all 2 digits
day_standardise = pad(day,2,'left','0')

%% step 2: rearrange the column vector by combining the 3 separate column
% vectors and inserting hyphens in between the string
combined_date = strcat(day_standardise,"-",month,"-",year)

%% step 3: convert to date-time format (ddmmyyyy)
datestring = datestr(combined_date,24)           % Just to help MATLAB recognise the format in 
datestring = datestr(combined_date,'ddmmyyy')    % Convert to ddmmyyyy
