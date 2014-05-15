% function [ out ] = Score1D( hist, train )
% %  Compute score for histogram given training set by computing EMD distance
% %  to each image histogram and inversely weighting distance.  Take the
% %  minimum distance of all training images
% 
% q = length(train(1,1,:));
% out = exp(-(Distance1D(hist, train(:,:,1)))^2/2);
% if (q > 1)
%     for i=2:q
%         newDist = exp(-(Distance1D(hist, train(:,:,i)))^2/2);
%         if (newDist < out)
%             out = newDist;
%         end
%     end
% end
% 
% end

function [ out ] = Score1D( hist, train )
%  Compute score for histogram given training set by computing EMD distance
%  to each image histogram and inversely weighting distance.

out = 0;
q = length(train(1,1,:));
for i=1:q
    out = out + exp(-(Distance1D(hist, train(:,:,i)))^2/2); 
end

out = out ./ q;

end