function imgRec = JPEGdecode(JPEGenc, subimg, qScale)

%%% Extract the first struct's elements %%%
firstStruct = JPEGenc{1};
qTableL = firstStruct.qTableL;
qTableC = firstStruct.qTableC;
DCL = firstStruct.DCL;
DCC = firstStruct.DCC;
ACL = firstStruct.ACL;
ACC = firstStruct.ACC;

%%% Extract the image dimensions from the last block struct %%%
lastElem = JPEGenc{size(JPEGenc, 2)};
H = lastElem.indVer * 8;
W = lastElem.indHor * 8;

imgY = uint8( zeros(H, W) );
imgB = uint8( zeros(H, W) );
imgR = uint8( zeros(H, W) );

counterToN = 2;

for i=1:8:H
    for j=1:8:W
    
        structY = JPEGenc{counterToN};
        huffY = structY.huffStream;
        counterToN = counterToN + 1;
        
        structB = JPEGenc{counterToN};
        huffB = structB.huffStream;
        counterToN = counterToN + 1;
              
        structR = JPEGenc{counterToN};
        huffR = structR.huffStream;
        counterToN = counterToN + 1;
        
        rleY = huffDec(huffY, DCL, ACL);        
        rleB = huffDec(huffB, DCC, ACC);
        rleR = huffDec(huffR, DCC, ACC);
        
        qBlockY = irunLength(rleY, 0);
        qBlockB = irunLength(rleB, 0);
        qBlockR = irunLength(rleR, 0);
        
        dctBlockY = dequantizeJPEG(qBlockY, qTableL, qScale);       
        dctBlockB = dequantizeJPEG(qBlockB, qTableC, qScale);
        dctBlockR = dequantizeJPEG(qBlockR, qTableC, qScale);
        
        blockY = uint8( iBlockDCT(dctBlockY) );
        blockB = uint8( iBlockDCT(dctBlockB) );
        blockR = uint8( iBlockDCT(dctBlockR) );
        
        imgY(i:i+7, j:j+7) = blockY;
        imgB(i:i+7, j:j+7) = blockB;
        imgR(i:i+7, j:j+7) = blockR;
        
    end
end

%%% Convert image back to RGB %%%
imgRec = convert2rgb(imgY, imgB, imgR, subimg);

end