function [ video ] = OutlineVideoComponent( video, componentVideo )
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here

frames = length(componentVideo(1,1,:));

for i=1:frames
    video(:,:,:,i) = OutlineRegion(video(:,:,:,i),componentVideo(:,:,i));
end


end

