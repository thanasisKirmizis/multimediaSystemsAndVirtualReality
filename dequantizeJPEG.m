function dctBlock = dequantizeJPEG(qBlock, qTable, qScale)

H = 8; 
W = 8; 
dctBlock = zeros(H, W);

%%% Scale the dequantization table %%%
newQTable = qScale * qTable;

%%% Dequantize every value of the DCT block %%%
for i=1:H
    for j=1:W
   
        dctBlock(i,j) = qBlock(i,j)*newQTable(i,j);
        
    end
end

end