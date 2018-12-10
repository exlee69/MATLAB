function [DJIAComponentChangeDate,DatePrevious] = DJIADateComponentChange(fullList)
% extract dates in which DJIA historical components changes
filteredData = regexprep(fullList,'[\n\r]+',' ');
myregexp = '(?<="></span><span class="mw-headline" id=").+?(?=">)';
dates = regexp(filteredData,myregexp,'match');
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
DJIAComponentChangeDate = datestr(combined_date,24)           
% Convert to ddmmyyyy
DJIAComponentChangeDate = datestr(combined_date,'ddmmyyyy')

% Get date of day before
DatePrevious = datetime(combined_date)
DatePrevious = dateshift(DatePrevious,'end','day','previous')
DatePrevious = datestr(DatePrevious,'ddmmyyyy')
DatePrevious = cellstr(DatePrevious)
DatePrevious(2:12,1) = DatePrevious(1:11,1)
DatePrevious{1,1} = datestr(datetime('today'),'ddmmyyyy')
DatePrevious(12,:) = []
end