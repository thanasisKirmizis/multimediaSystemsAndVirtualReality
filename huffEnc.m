function huffStream = huffEnc(runSymbols, huffDCTable, huffACTable)

huffStream = '';

%%% DC symbol encoding %%%
dcSymb = runSymbols(1,2);

% Find the category that the DC symbol belongs to using a loop %
if(dcSymb == 0)

    dcCategory = 0;                 
else

    dcCategory = fix(log2(abs(dcSymb))) + 1;
end

% Increase because it was zero-based but now we want one-based position %
dcPosition = dcCategory + 1;

% Get the corresponding code word for the DC category %
dcCodeWord = huffDCTable(dcPosition);

% Concatenate category of value to result to know how many bits to lookup next%
huffStream = strcat(huffStream, dcCodeWord);

% Concatenate sign of value to result (1 for positive 0 for negative)%
huffStream = strcat(huffStream, int2str(uint8(dcSymb>=0)));

% Concatenate abs of actual value to result %
huffStream = strcat(huffStream, dec2bin(abs(dcSymb)));

%%% AC symbols encoding %%%
for i=2:size(runSymbols,1)
   
    % Get the symbol to be encoded % 
    acSymb = runSymbols(i,2);
    
    % Find the category that the AC symbol belongs to using log2 %
    if(acSymb == 0)

        acPosition = 162; 
        acCodeWord = huffACTable(acPosition);
        huffStream = strcat(huffStream, acCodeWord);     %encoding of EOB
        break;
    else

        acCategory = fix(log2(abs(acSymb))) + 1;
    end
        
    % Get its preceding zeros %
    zeros = runSymbols(i,1);
    
    % Get the position based on the manual %
    acPosition = zeros*10 + acCategory;
    
    % Check for case where zeros > 15 %
    while(zeros > 15)
       acPosition = 161; 
       acCodeWord = huffACTable(acPosition);
       huffStream = strcat(huffStream, acCodeWord, '10');     %encoding of ZRL. 1 for positive sign and 0 for value = 0
       zeros = zeros - 16;
       acPosition = zeros*10 + acCategory;
    end
    
    % Check for case where acCategory = 0 (EOB) %
    if(acCategory == 0)
    
        acPosition = 161;
    end
    
    % Get the corresponding code word for the AC category %
    acCodeWord = huffACTable(acPosition);
    
    % Get the sign of actual value (1 for positive, 0 for negative) %
    sign = int2str(uint8(acSymb>=0));

    % Get the abs of actual value %
    actVal = dec2bin(abs(acSymb));
    
    % Concatenate the above strings to the result %
    huffStream = strcat(huffStream, acCodeWord, sign, actVal);

end

%%% Convert the output from cell to string %%%
huffStream = char(huffStream);

end