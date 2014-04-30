function [ out ] = Score1D( hist, train )
%  Compute score for histogram given training set by computing EMD distance
%  to each image histogram and inversely weighting distance.

out = 0;

for i=1:size(train,3)
    out = out + exp(-(Distance1D(hist, train(:,:,i)))^2/2);  %May have to reshape train....
end

end