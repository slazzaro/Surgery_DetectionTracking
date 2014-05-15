function [meanx, meany, radius] = GetCircleInfo( ComponentVideo, s)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%Just get circle from first frame of ComponentVideo.  Can also take average
% of means for all components of video but that would take longer

[meanx,meany,radius] = BinaryVidToCircle(ComponentVideo(:,:,:),s); %all
meanx = round(meanx);
meany = round(meany);
radius = round(radius);


end