function qBlock = quantizeJPEG(dctBlock, qTable, qScale)

H = 8; 
W = 8; 
qBlock = zeros(H, W);

%%% Scale the quantization table %%%
newQTable = qScale * qTable;

%%% Quantize every value of the DCT block %%%
for i=1:H
    for j=1:W
   
        qBlock(i,j) = round(dctBlock(i,j)/newQTable(i,j));
        
    end
end

end