function [ video ] = AddCircleToVideo( video, meanx, meany, radius )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(video(1,1,1,:))
    video(:,:,:,i) = AddCircleToImage( video(:,:,:,i), meanx, meany, radius, [0 0 0] );
end

end

