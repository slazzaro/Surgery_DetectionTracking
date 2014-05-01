function [ out ] = ScoreVideoToComponentVideo2( scoreVideo )
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
out = false(size(scoreVideo));

for i=1:length(scoreVideo(1,1,:))
    [L,num] = bwlabeln(scoreVideo(:,:,i));
    max = 0;
    component = 0;
    for j = 1:num
        temp = sum(sum(sum(L==j)));
        if (temp>max)
            component=j;
            max = temp;
        end
    end
    out(:,:,i) = (L==component);
end

end

