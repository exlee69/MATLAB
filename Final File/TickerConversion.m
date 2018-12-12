function [StandardisedCompanyName, CompiledTickers] = TickerConversion(Dataset,TickerUniverse)
StandardisedCompanyName = regexprep(Dataset,'Corporation','Corp');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'(\w\s)* & Co, Inc',' & Company');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Alcoa Inc','Alcoa Corp');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'AlliedSignal Incorporated','Honeywell International Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Altria Group Incorporated','Altria Group');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Altria Group, Incorporated','Altria Group');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'American International Group Inc','American International Group');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'AT&T Corp','AT&T Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Cisco Systems, Inc','Cisco Systems Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'DowDuPont Inc','Dowdupont Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Eastman Kodak Company','Eastman Kodak');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'EI du Pont de Nemours & Company','Dowdupont Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Exxon Corp','Exxon Mobil Corp');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'General Motors Corp','General Motors Company');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Honeywell International','Honeywell International Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Honeywell International Inc Inc','Honeywell International Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Intel Corporation','Intel Corp');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'International Business Machines Corp','International Business Machines');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Kraft Foods Inc','Mondelez Intl Cmn A');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Nike, Inc','Nike Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'JPMorgan Chase & Co','JP Morgan Chase & Co');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'SBC Communications Inc','AT&T Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'The Boeing','Boeing');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'The Coca','Coca');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'The Goldman Sachs Group, Inc','Goldman Sachs Group');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'The Home Depot, Inc','Home Depot');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'The Procter','Procter');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'The Travelers Companies, Inc','The Travelers Companies Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'The Walt','Walt');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'UnitedHealth Group Inc','Unitedhealth Group Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Verizon Communications, Inc','Verizon Communications Inc');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Wal-Mart Stores, Inc','Wal-Mart Stores');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Walmart Inc','Wal-Mart Stores');
StandardisedCompanyName = regexprep(StandardisedCompanyName,'Walgreens Boots Alliance, Inc','Walgreens Boots Alliance');
% MacDonalds
StandardisedCompanyName(1:3,8) = StandardisedCompanyName(4,5);
% convert companies in compiled dataset to its tickers
m = size(StandardisedCompanyName);
n = length(StandardisedCompanyName);
o = m(1,1);
CompiledTickers = StandardisedCompanyName;
for c = 1:o
    for b = 3:n
        a = find(strcmp(TickerUniverse(:,2), StandardisedCompanyName(c,b)));
        CompiledTickers(c,b) = TickerUniverse(a,1);
    end
end
end