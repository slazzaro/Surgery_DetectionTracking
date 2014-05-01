function [ out ] = Score1D( hist, train )
%  Compute score for histogram given training set by computing EMD distance
%  to each image histogram and inversely weighting distance.

out = 0;
q = length(train(1,1,:));
for i=1:q
    out = out + exp(-(Distance1D(hist, train(:,:,i)))^2/2);  %May have to reshape train....
end

end