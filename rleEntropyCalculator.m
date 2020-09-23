%%%																		
%%%	Auxiliary function to calculte the entropy of a table of runSymbols	
%%%																	

function entr = rleEntropyCalculator(runSymbols)

entr = 0;
howManyTimesEach = ones(size(runSymbols,1),1);

%%% Firstly calculate the probability of each symbol (a symbol is considered the pair (zeros, value) )%%%
unique_symbols = unique(runSymbols, 'rows');
[~, index] = ismember(runSymbols, unique_symbols, 'rows');
pdf = ( accumarray(index, howManyTimesEach) ) / size(runSymbols, 1);

%%% Then calculate the total entropy %%% 
for i=1:size(pdf, 1)
    
    entr = entr + pdf(i) * log2(pdf(i)) ;    
end

entr = -entr;

end