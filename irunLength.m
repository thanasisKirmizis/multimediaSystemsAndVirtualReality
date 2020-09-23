function qBlock = irunLength(runSymbols, DCpred)

H = 8; 
W = 8;
qBlock = zeros(W, H);

%%% Decode the DC coefficient seperately %%%
qBlock(1,1) = runSymbols(1, 2) + DCpred;

%%% Decode the rest AC coefficients %%%
i = 1;
j = 1;

for k=2:size(runSymbols,1)
    
    runLength = runSymbols(k,1);
    value = runSymbols(k,2);
    loopCounter = 0;
    
    % Traversal loop %
    while(1)

        % Traverse the block in zig-zag fashion to get to the next non-zero element position %        
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
     
        % If we reached non-zero element position, assign the value and break loop %     
        if(loopCounter >= runLength)                                
            qBlock(i,j) = value;
            break;
        end
        
        loopCounter = loopCounter + 1;
        
    end
        
end

end