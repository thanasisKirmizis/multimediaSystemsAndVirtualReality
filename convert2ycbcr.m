function [imageY, imageCb, imageCr] = convert2ycbcr(imageRGB, subimg)

%%% Get and adjust width and height so that they are multiples of 8 %%%
H = size(imageRGB, 1) - mod(size(imageRGB, 1), 8);
W = size(imageRGB, 2) - mod(size(imageRGB, 2), 8);

%%% Initialize arrays %%%
imageY =  uint8( zeros(H, W) );
imageCb = uint8( zeros(H, W) );
imageCr = uint8( zeros(H, W) );

r = double( imageRGB(:, :, 1) );
g = double( imageRGB(:, :, 2) );
b = double( imageRGB(:, :, 3) );

%%% Define the subsampling factor %%%
subFactor = 4;

if(subimg == [4 2 2])
    
    subFactor = 2;
elseif(subimg == [4 2 0])
    
    subFactor = 1;
end

%%% Transformation coefficients %%%
TY = [0.299 0.587 0.114];
TCb = [-0.1687 -0.3313 0.5];
TCr = [0.5 -0.4187 -0.0813];

%%% Transform every pixel from RGB to YCbCr based on the Wikipedia formula  and the corresponding subsampling %%%
for i=1:H
    for j=1:W
   
        imageY(i,j) = TY*[r(i,j); g(i,j); b(i,j)];
        
        % Apply 4:2:2 subsampling %
        if(subFactor == 2)
            
            if(mod(j,2) == 1)
                
                imageCb(i,j) = 128 + TCb*[r(i,j); g(i,j); b(i,j)];
                imageCr(i,j) = 128 + TCr*[r(i,j); g(i,j); b(i,j)];
            end
        % Apply 4:2:0 subsampling %
        elseif(subFactor == 1)
            
            if(mod(j,2) == 1 && mod(i,2) == 1)
                
                imageCb(i,j) = 128 + TCb*[r(i,j); g(i,j); b(i,j)];
                imageCr(i,j) = 128 + TCr*[r(i,j); g(i,j); b(i,j)];
            end
        % No subsampling (4:4:4) %
        else
           
            imageCb(i,j) = 128 + TCb*[r(i,j); g(i,j); b(i,j)];
            imageCr(i,j) = 128 + TCr*[r(i,j); g(i,j); b(i,j)];
        end
        
    end
end

end