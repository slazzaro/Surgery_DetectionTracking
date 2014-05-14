function [ out ] = Histograms1D( image, s )
%  Create for each pixel three 1D histograms of color intensity in a 2n by
%  2n window around that pixel.  image is a NxNx3 matrix of integers
%  [0,255].  w must divide 256.
height = length(image(:,1,1));
width = length(image(1,:,1));
discHeight = height/s;
discWidth = width/s;
out = zeros(8,8,discHeight,discWidth);

for i=1:discHeight
    for j=1:discWidth
        imagePart = image((i-1)*s+1:i*s,(j-1)*s+1:j*s,:);
        grayCoMat = graycomatrix(rgb2gray(imagePart));
        grayCoMat = grayCoMat ./ sum(grayCoMat(:));
        out(:,:,i,j) = grayCoMat;
    end
end