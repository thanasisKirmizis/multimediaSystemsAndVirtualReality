function imgCmp = JPEGdecodeStream(JPEGencStream, subimg, qScale)

%%%%% Here cheat a little with the quantization and Huffman tables %%%%%

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

%%%%%%%%%%%%%%%%%%%%

%%%%% From the JPEG encoded bitstream, produce the encoded structure of the image %%%%%

%%% Firstly find the Start Of Scan marker %%%
for i=1:(size(JPEGencStream, 1) - 1)
   
    if(JPEGencStream(i) == 255 && JPEGencStream(i+1) == 218)
    
        startOfImageIndex = i+14;
        break;
    end
end

if(i == (size(JPEGencStream, 1) - 1))
   
    disp('Start Of Scan Marker Not Found in Image!');
end

%%% Then extract the image bytes and save them to an encoded structure %%%


%%%%%%%%%%%%%%%%%%%%


%%% From the encoded structure, reproduce the original image %%%
imgCmp = JPEGdecode(JPEGenc, subimg, qScale);

end