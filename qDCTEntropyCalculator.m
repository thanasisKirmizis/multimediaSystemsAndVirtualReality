%%%																		
%%%	Auxiliary function to calculte the entropy of a quantized DCT Image	
%%%																	

function entr = qDCTEntropyCalculator(qDCTImage)

symbols = qDCTImage(:);

theSize = size(symbols,1);
entr = 0;
howManyTimesEach = ones(theSize,1);

%%% Firstly calculate the probability of each symbol %%%
unique_symbols = unique(symbols);
[~, index] = ismember(symbols, unique_symbols);
pdf = ( accumarray(index, howManyTimesEach) ) / theSize;

%%% Then calculate the total entropy %%% 
for i=1:size(pdf, 1)
    
    entr = entr + pdf(i) * log2(pdf(i)) ;    
end

entr = -entr;

end