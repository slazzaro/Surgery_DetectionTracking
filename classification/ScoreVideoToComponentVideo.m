function [ out, component ] = ScoreVideoToComponentVideo( scoreVideo )
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here

[L,num] = bwlabeln(scoreVideo);
max = 0;
component = 0;
for i = 1:num
    temp = sum(sum(sum(L==i)));
    if (temp>max)
        component=i;
        max = temp;
    end
end
if component == 0
    out = scoreVideo;
else
    out = (L==component);
end

end

