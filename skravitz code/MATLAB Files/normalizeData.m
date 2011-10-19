function Xnorm = normalizeData(X)
% Takes data series, with each column corresponding to a single variable,
% and normalizes each column so that the variance is equal to 1
% Inputs
%   X       Data to be normalized, with columns corresponding to variables
% Outputs
%   Xnorm   Normalized data

norms = sqrt(var(X));
Xsize = size(X);
Xnorm = zeros(Xsize);

for colInd = 1:Xsize(2)
   Xnorm(:,colInd) = X(:,colInd)/norms(colInd); 
end