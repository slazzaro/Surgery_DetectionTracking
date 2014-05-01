function [ out ] = Histograms1DOpt2( image, n, s, w)
%  This function is a different take on the windowization/histogramization
%  problem.  the variable s must divide the height and width of the image.
%  The image will be discretized into s-by-s windows.  For every point on
%  the grid defined by these s-by-s windows the n windows to the leftm
%  right top and bottom of this point (except for points near boundaries)
%  will form a larger window whose histogram will be taken.  This histogram
%  will represent that pixel at the grid intersection.  The result will be
%  a (height/s + 1)x(width/s + 1)x(256/w)x(3) array.

height = length(image(:,1,1));
width = length(image(1,:,1));
discHeight = height/s;
discWidth = width/s;
out = zeros(256/w,3,discHeight+1,discWidth+1);

smallWindowHistograms = zeros(256/w,3,discHeight,discWidth);
for i=1:discHeight
    for j=1:discWidth
        smallWindowHistograms(:,:,i,j) = SimpleNonnormalizedHist1D(image((i-1)*s+1:i*s,(j-1)*s+1:j*s,:),w);
    end
end

for Y=1:discHeight+1
    for X=1:discWidth+1
        for i=max(Y-n,1):min(Y+n-1,discHeight)
            for j=max(X-n,1):min(X+n-1,discWidth)
                out(:,:,Y,X) = out(:,:,Y,X) + smallWindowHistograms(:,:,i,j);
            end
        end
        out(:,:,Y,X) = out(:,:,Y,X)/(s*s*(min(Y+n-1,discHeight)-max(Y-n,1)+1)*(min(X+n-1,discWidth)-max(X-n,1)+1));
    end
end




end

