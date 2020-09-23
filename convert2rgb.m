function imageRGB = convert2rgb(imageY, imageCb, imageCr, subimg)

%%% Convert input image from [0 255] to [0 1] %%%
imageY = im2double(imageY);
imageCb = im2double(imageCb);
imageCr = im2double(imageCr);

%%% Get some necessary values %%%
H = size(imageY, 1);
W = size(imageY, 2);

%%% Initialize arrays %%%
R = zeros(H, W);
G = zeros(H, W);
B = zeros(H, W);

%%% Define the subsampling factor %%%
subFactor = 4;

if(subimg == [4 2 2])
    
    subFactor = 2;
elseif(subimg == [4 2 0])
    
    subFactor = 1;
end

%%% Transform every pixel from YCbCr to RGB based on the Wikipedia formula %%%
for i=1:H
    for j=1:W
   
        % Apply 4:2:2 supersampling with nearest neighbor method (nn = left pixel) %
        if(subFactor == 2)
            
            if(mod(j,2) == 0)
                
                R(i,j) = imageY(i,j) + 1.402*(imageCr(i,j-1) - 0.5);
                G(i,j) = imageY(i,j) - 0.344136*(imageCb(i,j-1) - 0.5) - 0.714136*(imageCr(i,j-1) - 0.5);
                B(i,j) = imageY(i,j) + 1.772*(imageCb(i,j-1) - 0.5);
            else
                
                R(i,j) = imageY(i,j) + 1.402*(imageCr(i,j) - 0.5);
                G(i,j) = imageY(i,j) - 0.344136*(imageCb(i,j) - 0.5) - 0.714136*(imageCr(i,j) - 0.5);
                B(i,j) = imageY(i,j) + 1.772*(imageCb(i,j) - 0.5); 
            end
        % Apply 4:2:0 supersampling with nearest neighbor method (nn = left or above or left&above pixel) %
        elseif(subFactor == 1)
            
            if(mod(j,2) == 0)
                
                if(mod(i,2) == 0)       %sample from left & above
                   
                    R(i,j) = imageY(i,j) + 1.402*(imageCr(i-1,j-1) - 0.5);
                    G(i,j) = imageY(i,j) - 0.344136*(imageCb(i-1,j-1) - 0.5) - 0.714136*(imageCr(i-1,j-1) - 0.5);
                    B(i,j) = imageY(i,j) + 1.772*(imageCb(i-1,j-1) - 0.5);
                
                else                    %sample from left
                    
                    R(i,j) = imageY(i,j) + 1.402*(imageCr(i,j-1) - 0.5);
                    G(i,j) = imageY(i,j) - 0.344136*(imageCb(i,j-1) - 0.5) - 0.714136*(imageCr(i,j-1) - 0.5);
                    B(i,j) = imageY(i,j) + 1.772*(imageCb(i,j-1) - 0.5);
                end
            else
                
                if(mod(i,2) == 0)       %sample from above
                   
                    R(i,j) = imageY(i,j) + 1.402*(imageCr(i-1,j) - 0.5);
                    G(i,j) = imageY(i,j) - 0.344136*(imageCb(i-1,j) - 0.5) - 0.714136*(imageCr(i-1,j) - 0.5);
                    B(i,j) = imageY(i,j) + 1.772*(imageCb(i-1,j) - 0.5);
                
                else                    %sample from itself
                    
                    R(i,j) = imageY(i,j) + 1.402*(imageCr(i,j) - 0.5);
                    G(i,j) = imageY(i,j) - 0.344136*(imageCb(i,j) - 0.5) - 0.714136*(imageCr(i,j) - 0.5);
                    B(i,j) = imageY(i,j) + 1.772*(imageCb(i,j) - 0.5);
                end
            end     
        % No supersampling (4:4:4) %
        else
           
            R(i,j) = imageY(i,j) + 1.402*(imageCr(i,j) - 0.5);
            G(i,j) = imageY(i,j) - 0.344136*(imageCb(i,j) - 0.5) - 0.714136*(imageCr(i,j) - 0.5);
            B(i,j) = imageY(i,j) + 1.772*(imageCb(i,j) - 0.5);
        end
        
    end
end

%%% Convert output image from [0 1] to [0 255] %%%
R = im2uint8(R);
G = im2uint8(G);
B = im2uint8(B);

%%% Concatenate the final 3 colors into a single table %%%
imageRGB = cat(3, R, G, B);

end