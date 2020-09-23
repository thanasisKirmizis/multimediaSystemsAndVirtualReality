function runSymbols = runLength(qBlock, DCpred)

H = 8; 
W = 8;

runSymbolsTemp = zeros(H*W, 2);

%%% The DC coefficient is encoded seperately from the AC ones and based on this equation %%%
diff = qBlock(1,1) - DCpred;
runSymbolsTemp(1, :) = [0 diff];

i = 1;
j = 2;
k = 2;
lenOfRun = 0;

%%% Traversal loop %%%
while((j <= W) && (i <= H))
    
    % Do the assigning of values %
    
    if(qBlock(i,j) == 0)                                %If encountered a zero element, increase the length and continue the run
        lenOfRun = lenOfRun + 1;
    else                                                %If encountered a non-zero element, stop the run and assign the pair of values
        runSymbolsTemp(k, :) = [lenOfRun qBlock(i,j)];
        k = k + 1;
        lenOfRun = 0;
    end
    
    % Traverse the block in zig-zag fashion to get the next element %
    
    if (mod(i + j, 2) == 1)                 % going down
        
        if (j == 1)                         % if we got to the first column     
            
            if (i == H)
                j = j + 1;
            else
                i = i + 1;
            end
            
        elseif ((i == H) && (j < W))        % if we got to the last line
            j = j + 1;
            
        elseif ((j > 1) && (i < H))         % all other cases
            j = j - 1;
            i = i + 1;
        end
        
    else                                    % going up
        
       if ((j == W) && (i <= H))            % if we got to the last column
            i = i + 1;
        
       elseif (i == 1)                      % if we got to the first line
            
            if (j == W)
                i = i + 1;
            else
              j = j + 1;
            end
            
       elseif ((j < W) && (i > 1))          % all other cases
            j = j + 1;
            i = i - 1;
       end
      
    end
    
    if ((j == W) && (i == H))               % bottom right element
        runSymbolsTemp(k, :) = [lenOfRun qBlock(i,j)];
        break;
    end
    
end

%%% Trim the unnecessary zeros allocated to the runSymbols buffer %%%
runSymbols = zeros(k, 2);

for i=1:k
    
    runSymbols(i, :) = runSymbolsTemp(i, :);
    
end

end