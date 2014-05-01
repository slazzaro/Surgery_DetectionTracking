function [ video ] = ComponentVideoToCircleVideo( video, ComponentVideo, s)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(video(1,1,1,:))
    [meanx,meany,radius] = BinaryToCircle(ComponentVideo(:,:,i),s);
    meanx = round(meanx);
    meany = round(meany);
    radius = round(radius);
    video(:,:,:,i) = AddCircle( video(:,:,:,i), meanx, meany, radius );
end

end

