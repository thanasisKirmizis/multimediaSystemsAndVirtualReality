function JPEGencStream = JPEGencodeStream(img, subimg, qScale)

%%% Define and initialize some important variables %%%
outfile = 'outputImage.jpg';
JPEGencStream = [];

zigZagOrder = [ 1 2 9 17 10 3 4 11 ...
                18 25 33 26 19 12 5 6 ...
                13 20 27 34 41 49 42 35 ...
                28 21 14 7 8 15 22 29  ...
                36 43 50 57 58 51 44 37 ...
                30 23 16 24 31 38 45 52 ...
                59 60 53 46 39 32 40 47 ...
                54 61 62 55 48 56 63 64];
            
%%% Get and adjust width and height so that they are multiples of 8 %%%
H = size(img, 1) - mod(size(img, 1), 8);
W = size(img, 2) - mod(size(img, 2), 8);

%%% Encode to JPEG image %%%
enc = JPEGencode(img, subimg, qScale);

%%% Extract tables from the first encoded element %%%
firstElement = enc{1};
quantLumMatrix = firstElement.qTableL;
quantChromMatrix = firstElement.qTableC;
DCL = firstElement.DCL;
DCC = firstElement.DCC;
ACL = firstElement.ACL;
ACC = firstElement.ACC;    

%%% Encode the initial bytes according to the JPEG manual %%%
SOIString = 'ff d8 ff e0 00 10 4a 46 49 46 00 01 01 00 00 01 00 01 00 00';
JPEGencStream = [JPEGencStream; hex2dec(strsplit(SOIString))];

%%%%%%%%%%%%%%%%%%%%

%%% Encode the Quantization tables according to the JPEG manual %%%
DQT(1) = hex2dec('FF');
DQT(2) = hex2dec('DB');
DQT(3) = hex2dec('00');
DQT(4) = hex2dec('84'); %Lq = 132
DQT(5) = hex2dec('00'); %Pq&Tq for Y

offset = 5;
for i=1:64
    offset = offset + 1;
    DQT(offset) = quantLumMatrix(zigZagOrder(i));
end
offset = offset + 1;

DQT(offset) = hex2dec('01'); %Pq&Tq for Cb_Cr
for i=1:64
    offset = offset + 1;
    DQT(offset) = quantChromMatrix(zigZagOrder(i));
end

JPEGencStream = [JPEGencStream; DQT'];

%%%%%%%%%%%%%%%%%%%%

%%% Encode Start of Frame according to the JPEG manual %%%
SOF(1) = hex2dec('FF');
SOF(2) = hex2dec('C0');
SOF(3) = hex2dec('00');
SOF(4) = 17;                                        %SOF header length
SOF(5) = 8;                                         %Sample precision in bits
SOF(6) = bitand(bitshift(H, -8), hex2dec('FF'));    %MSB of Height
SOF(7) = bitand(H, hex2dec('FF'));                  %LSB of Height
SOF(8) = bitand(bitshift(W, -8), hex2dec('FF'));    %MSB of Width
SOF(9) = bitand(W, hex2dec('FF'));                  %LSB of Width
SOF(10) = 3;                                        %Number of image components
index = 11;
CompID = [1 2 3];                                   %Component identifier
HsampFactor = [1 1 1];                              %Height sampling factor of each component
VsampFactor = [1 1 1];                              %Width sampling factor of each component
QtableNumber = [0 1 1];                             %Which quantization table to pick for each component

for i = 1:SOF(10)
    SOF(index) = CompID(i);
    index = index + 1;
    SOF(index) = bitshift(HsampFactor(i), 4) + VsampFactor(i);
    index = index + 1;
    SOF(index) = QtableNumber(i);
    index = index + 1;
end

JPEGencStream = [JPEGencStream; SOF'];

%%%%%%%%%%%%%%%%%%%%

%%% Encode Huffman Tables according to the JPEG manual %%%
offset = 1;
Lh = [31 181 31 181];
Tc = [0 1 0 1];
Th = [0 0 1 1];

for i=1:4       %For each of the 4 Huffman tables (first the DCs, then the ACs)

    DHT(offset) = hex2dec('FF');
    offset = offset + 1;
    DHT(offset) = hex2dec('C4');
    offset = offset + 1;
    
    DHT(offset) = 0;            %MSB of DHT header length
    offset = offset + 1;
    DHT(offset) = Lh(i);        %LSB of DHT header length
    offset = offset + 1;
    
    if(i == 1)
        table = DCL;
    elseif(i == 2)      
        table = ACL;
    elseif(i == 3)
        table = DCC;
    else
        table = ACC;
    end
    
    DHT(offset) = bitshift(Tc(i), 4) + Th(i);
    offset = offset + 1;
    
    for j=1:16  %For each code word length
        
        DHT(offset) = 0;
        for k=1:size(table,1)
            if(length(table{k}) == j)
                DHT(offset) = DHT(offset) + 1;
            end
        end
        L(j) = DHT(offset);     %Also keep an array with the number of code words of Length j
        
        offset = offset + 1;
    end
    
    for j=1:16
        
            found = 0;
            for m=1:size(table,1)
               
                if(length(table{m}) == j)
                    
                    found = found + 1;
                    DHT(offset) = m;
                    offset = offset + 1;
                    if(found == L(j))
                        
                        break;
                    end
                end
            end
            
    end
    
end

JPEGencStream = [JPEGencStream; DHT'];

%%% Encode Start of Scan according to the JPEG manual %%%
SOS(1) = hex2dec('FF');
SOS(2) = hex2dec('DA');
SOS(3) = hex2dec('00');
SOS(4) = 12;
SOS(5) = 3;
index = 6;
CompID = [1 2 3];
DCtableNumber = [0 1 1];
ACtableNumber = [0 1 1];

for i = 1:SOS(5)
    SOS(index) = CompID(i);
    index = index + 1;
    SOS(index) = bitshift(DCtableNumber(i), 4) + ACtableNumber(i);
    index = index + 1;
end
SOS(index) = 0;
index = index + 1;
SOS(index) = 63;
index = index + 1;
SOS(index) = bitshift(0, 4) + 0;
index = index + 1;

JPEGencStream = [JPEGencStream; SOS'];

%%%%%%%%%%%%%%%%%%%%

%%% Encode the image bytes according to the JPEG manual %%%
for i=2:size(enc,2);
    
    stream = enc{i}.huffStream;
    streamInBytes = [];
    offset = 1;
    modulo = mod(length(stream), 8);
    
    if(modulo > 0)
        
        lastByte = stream(offset:offset+modulo-1);
        byteInDec = bin2dec(lastByte);
        streamInBytes = [streamInBytes byteInDec];
        offset = offset + modulo;
    end
    
    while(offset <= length(stream) - 7)
       
        oneByte = stream(offset:offset+7);
        byteInDec = bin2dec(oneByte);
        
        %Byte stuffing in case byte == '0xFF'
        if(byteInDec == 255)
           
            streamInBytes = [streamInBytes byteInDec 0];
        else
           
            streamInBytes = [streamInBytes byteInDec];
        end
        
        offset = offset + 8;
    end
    
    JPEGencStream = [JPEGencStream; streamInBytes'];
    
end

%%%%%%%%%%%%%%%%%%%%

%%% Encode the ending bytes according to the JPEG manual %%%
EOIString = 'ff d9';
JPEGencStream = [JPEGencStream; hex2dec(strsplit(EOIString))];

%%%%%%%%%%%%%%%%%%%%

%%% Save the binary output as a .jpg file %%%
fid = fopen(outfile, 'w');
fwrite(fid, JPEGencStream, 'uint8');
fclose(fid);

end