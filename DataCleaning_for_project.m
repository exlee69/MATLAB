%% Extract DJIA components
WebsiteOfHistoricalComponents = 'https://en.wikipedia.org/wiki/Historical_components_of_the_Dow_Jones_Industrial_Average';
fullList = webread(WebsiteOfHistoricalComponents);

%% Obtain list of companies to be used as DJIA component

% cleaning data

% replace new line with white space in text documents
str1 = regexprep(fullList,'[\n\r]+',' ')
myRegExp = '(?<=<td>).+?(?=</td>)';
filteredData = regexp(str1,myRegExp,'match')

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


%transpose
filteredDatav2 = filteredDatav2.'


%for loop to remove components that are not company names

%for i = 1:length(filteredData)
    %if DJIADates(i,1)
    %end
    
       