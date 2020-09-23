function JPEGenc = JPEGencode(img, subimg, qScale)
    
%%% Load the quantization tables %%%
qTableL = load('lumQuantTable');
qTableL = qTableL.lumQuantTable;
qTableC = load('chromQuantTable');
qTableC = qTableC.chromQuantTable;

%%% Load the Huffman Tables %%%
DCL = load('lumDCHuff.mat');
DCL = DCL.lum_DC;
DCC = load('chromDCHuff.mat');
DCC = DCC.chrom_DC;
ACL = load('lumACHuff.mat');
ACL = ACL.lum_AC;
ACC = load('chromACHuff.mat');
ACC = ACC.chrom_AC;

%%% Build the first struct of the output cell array %%%
firstStruct.qTableL = qTableL;
firstStruct.qTableC = qTableC;
firstStruct.DCL = DCL;
firstStruct.DCC = DCC;
firstStruct.ACL = ACL;
firstStruct.ACC = ACC;

%%% Fill the output cell array with the first struct %%%
JPEGenc = {firstStruct};
counterToN = 2;

%%% Convert image to YCbCr %%%
[convImageY, convImageB, convImageR] = convert2ycbcr(img, subimg);
H = size(convImageY, 1);
W = size(convImageY, 2);


%%% Process every block and fill the corresponding values of the block in the ouput %%%
for i=1:8:H
    for j=1:8:W
        
        indHor = fix( j/8 ) + 1;
        indVer = fix( i/8 ) + 1;
        
        blockY = convImageY(i:i+7, j:j+7);
        blockB = convImageB(i:i+7, j:j+7);
        blockR = convImageR(i:i+7, j:j+7);
        
        dctBlockY = blockDCT(blockY);
        dctBlockB = blockDCT(blockB);
        dctBlockR = blockDCT(blockR);
        
        qBlockY = quantizeJPEG(dctBlockY, qTableL, qScale);         
        qBlockB = quantizeJPEG(dctBlockB, qTableC, qScale);
        qBlockR = quantizeJPEG(dctBlockR, qTableC, qScale);
        
        rleY = runLength(qBlockY, 0);
        rleB = runLength(qBlockB, 0);
        rleR = runLength(qBlockR, 0);
        
        huffY = huffEnc(rleY, DCL, ACL);
        huffB = huffEnc(rleB, DCC, ACC);
        huffR = huffEnc(rleR, DCC, ACC);
        
        restStructsY.blkType = 'Y';
        restStructsY.indHor = indHor;
        restStructsY.indVer = indVer;
        restStructsY.huffStream = huffY;
        
        restStructsB.blkType = 'Cb';
        restStructsB.indHor = indHor;
        restStructsB.indVer = indVer;
        restStructsB.huffStream = huffB;
        
        restStructsR.blkType = 'Cr';
        restStructsR.indHor = indHor;
        restStructsR.indVer = indVer;
        restStructsR.huffStream = huffR;
        
        % Fill the output cell array with the rest structs with order Y -> Cb -> Cr%
        JPEGenc(counterToN) = {restStructsY};
        counterToN = counterToN + 1;
        JPEGenc(counterToN) = {restStructsB};
        counterToN = counterToN + 1;
        JPEGenc(counterToN) = {restStructsR};
        counterToN = counterToN + 1;
        
    end
end

end