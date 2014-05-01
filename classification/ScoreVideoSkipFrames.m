function [ ScoreVideo ] = ScoreVideoSkipFrames( ScoreVideo, Skip )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
for i = length(ScoreVideo(1,1,:))
    ScoreVideo(:,:,i) = ScoreVideo(:,:,floor(i/Skip)+1);
end


end

