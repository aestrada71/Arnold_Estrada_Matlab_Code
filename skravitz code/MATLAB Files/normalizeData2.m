function Xnorm = normalizeData2(X)
% Takes data series, with each column corresponding to a single variable,
% and normalizes each column so that the mean is 0 and the variance is 1
% Inputs
%   X       Data to be normalized, with columns corresponding to variables
% Outputs
%   Xnorm   Normalized data

norms = sqrt(var(X));
means = mean(X);
Xsize = size(X);
Xnorm = zeros(Xsize);

for colInd = 1:Xsize(2)
   Xnorm(:,colInd) = (X(:,colInd)-means(colInd))/norms(colInd); 
end