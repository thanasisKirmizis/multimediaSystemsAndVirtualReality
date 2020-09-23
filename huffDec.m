function runSymbols = huffDec(huffStream, huffDCTable, huffACTable)

streamLen = length(huffStream);
runSymbols = [];

%%% Make a hashmap out of the huffAC table so that it acts as a faster lookup table %%% 
huffACMap = containers.Map(huffACTable, 1:length(huffACTable));

%%% Define the max length of the code words and the number of combinations for DC based on the manual %%%
maxLenDC = 11;      %this is for chrominance, but for luminance it's 9
numOfCombosDC = 11;

%%% Decode the DC coefficient %%%
j = 1;
while(j < maxLenDC)

    c = huffStream(1:j);      
    ind=1;
    while(ind <= numOfCombosDC && ~strcmp(huffDCTable(ind), c))      

        ind = ind+1;
    end

    % Found the correct code word %
    if(ind <= numOfCombosDC)

        % Get the non-zero value of element %
        dcCategory = ind - 1;
        dcValueSign = huffStream(j+1);
        dcValueBits = huffStream(j+2 : j+dcCategory+1);         %the actual value occupies size+1 positions in the huffstream (where size = category and +1 is for the sign)
        if(dcValueSign == '0')
            
            dcValue = -1 * bin2dec(dcValueBits) ;
        else
            
            dcValue = bin2dec(dcValueBits) ;
        end
        
        % Update the output result with the DC runlength value %
        runSymbols = [runSymbols; [0 dcValue]];
        
        % Update the j to know where to initialize i later %
        j = j+1+dcCategory;
        
        break;
    else
        
        j = j+1;
    end
end

%%% Define the max length of the code words and the number of combinations for AC based on the manual %%%
maxLenAC = 16;
precZerosForZRL = 0;
flagZRL = 0;
flagEOB = 0;

%%% Decode all the AC coefficients %%%
i = j+1;
while(i <= streamLen)
    
    j = 1;
    while(j < maxLenAC)          
            
        % Search for the next code word with length = j %
        c = huffStream(i:i+j);             
        
        % Found the next code word %
        if(isKey(huffACMap, c))
            
            ind = huffACMap(c);
            
            % Take care of EOB and ZRL cases %
            if(ind == 162)
                
                restZeros = 64 - sum(runSymbols(:,1)) - size(runSymbols, 1);
                runSymbols = [runSymbols; [restZeros 0]];
                flagEOB = 1;
                break;
            elseif(ind == 161)
                
                precZerosForZRL = precZerosForZRL + 16;
                flagZRL = 1;
            else
                                
                flagZRL = 0;
            end
            
            % Get the non-zero value of element %
            acCategory = mod(ind - 1,10) + 1;           
            acValueSign = huffStream(i+j+1);
            acValueBits = huffStream(i+j+2 : i+j+acCategory+1);         %the actual value occupies size+1 positions in the huffstream (where size = category and +1 is for the sign)
            if(acValueSign == '0')

                acValue = -1 * bin2dec(acValueBits) ;
            else

                acValue = bin2dec(acValueBits) ;
            end
            
            % Get the number of preceding zeros %
            zeros = fix(ind/10);
            
            % Update the output result with the AC runlength value %            
            if(precZerosForZRL > 0 && flagZRL == 0)
               
                % Take care of ZRL case %
                if(acValue == 0)
                    
                    runSymbols = [runSymbols; [precZerosForZRL-1 acValue]];
                else
                    
                    runSymbols = [runSymbols; [precZerosForZRL acValue]];                    
                end
                
                precZerosForZRL = 0;
                
                % Update the j to know where to continue i later %
                j = j+1+acCategory;
                break;
            else
                
                runSymbols = [runSymbols; [zeros acValue]];
                
                % Update the j to know where to continue i later %
                j = j+1+acCategory;
                break;
            end
        else
            
            j = j+1;
        end
    end
    
    if(flagEOB == 1)
        
        break;
    else
        
        i = i+j+1;
    end
end


end