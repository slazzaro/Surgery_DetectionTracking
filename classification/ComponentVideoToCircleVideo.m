function [ video ] = ComponentVideoToCircleVideo( video, ComponentVideo, s)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

color = [0 0 0];

for i=1:length(video(1,1,1,:))
    [meanx,meany,radius] = BinaryToCircle(ComponentVideo(:,:,i),s);
    meanx = round(meanx);
    meany = round(meany);
    radius = round(radius);
    video(:,:,:,i) = AddCircleToImage( video(:,:,:,i), meanx, meany, radius, color );
end

end

