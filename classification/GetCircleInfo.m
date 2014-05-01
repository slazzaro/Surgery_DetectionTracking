function [meanx, meany, radius] = GetCircleInfo( ComponentVideo, s)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%Just get circle from first frame of ComponentVideo.  Can also take average
% of means for all videos but that would take longer
%TODO: experiment with taking mean of the x's, y's and radius's returned
[meanx,meany,radius] = BinaryToCircle(ComponentVideo(:,:,1),s);
meanx = round(meanx);
meany = round(meany);
radius = round(radius);

% color = [0 0 0];
% 
% for i=1:length(video(1,1,1,:))
%     [meanx,meany,radius] = BinaryToCircle(ComponentVideo(:,:,i),s);
%     meanx = round(meanx);
%     meany = round(meany);
%     radius = round(radius);
%     video(:,:,:,i) = AddCircleToImage( video(:,:,:,i), meanx, meany, radius, color );
% end

end