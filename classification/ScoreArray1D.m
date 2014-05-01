function [ out ] = ScoreArray1D( histArray, train )
%  Compute score for histogram given training set by computing EMD distance
%  to each image histogram and inversely weighting distance.
height = length(histArray(1,1,:,1));
width = length(histArray(1,1,1,:));
out = zeros(height,width);

for X = 1:width
    for Y = 1:height
        out(Y,X) = Score1D(histArray(:,:,Y,X),train);
    end
end

end