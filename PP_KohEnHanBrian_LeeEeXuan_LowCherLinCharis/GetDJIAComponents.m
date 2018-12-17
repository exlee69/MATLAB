function companies = GetDJIAComponents(fullList)
filteredData = regexprep(fullList,'[\n\r]+',' ');
myRegExp = '(?<=<td>).+?(?=</td>)'; 
filteredData = regexp(filteredData,myRegExp,'match');
filteredData = filteredData.';
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
companies = pad(companies,40,'right');
companies = regexprep(companies,'\s\W\s{5,29}','');
companies = strtrim(companies);
end