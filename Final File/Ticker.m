function TickerUniverse = Ticker(NYSE,NASDAQ)
TickerUniverse = [NASDAQ; NYSE];
% remove repeated datasets
TickerUniverse = unique(TickerUniverse);
TickerUniverse = table2cell(TickerUniverse);
% remove unnecessary data (JP Morgan)
TickerUniverse(3305,:)=[];
TickerUniverse(3298,:)=[];
TickerUniverse(198,:)=[];
end