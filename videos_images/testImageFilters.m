function [ noSmallStructures ] = testImageFilters( name, filterVal, frameToFilter, shouldShowDark )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% http://www.mathworks.com/help/images/examples/texture-segmentation-using-texture-filters.html

vidObj = VideoReader(name);
veins = rgb2gray(read(vidObj,frameToFilter));

%veins = edge(veins, 'canny'); %good ones are canny, log and zerocross
veins = rangefilt(veins); %texture filter
figure, imshow(veins)

if shouldShowDark == 1
    noDarkObjs = imextendedmin(veins,filterVal);
else
    noDarkObjs = imextendedmax(veins,filterVal);
end

figure, imshow(noDarkObjs)
sedisk = strel('disk',2);
noSmallStructures = imopen(noDarkObjs, sedisk);
imshow(noSmallStructures)

end

