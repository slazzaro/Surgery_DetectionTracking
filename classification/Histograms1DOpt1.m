function [ out ] = Histograms1DOpt1( image, n, w, sx, sy )
%  Create for each pixel three 1D histograms of color intensity in a 2n by
%  2n window around that pixel.  image is a (height)x(width)x3 matrix of integers
%  [0,255].  w must divide 256.  
height = length(image(:,1,1));
width = length(image(1,:,1));
out = zeros(height/sy,width/sx,256/w,3);



for i = 1:3 %i will control the color (R,G,B)
    for X=1:sx:width %X will control the x-coordinate of the central pixel
        left = max(1,X-n);
        right = min(width,X+n);
        out(1,(X-1)/sx+1,:,i) = SimpleNonnormalizedHist1D(image( 1:1+n, left:right, i ),w);
        for Y=sy+1:sy:height %Y will control the y-coordinate of the central pixel
            out((Y-1)/sy+1,(X-1)/sx+1,:,i);
            for x=max(1,X-n):min(width,X+n)
                for y=max(1,Y-n-sy):Y-n-1
                    hue = image(y,x,i);
                    bin = (hue+1)/w;
                    out((Y-1)/sy+1,(X-1)/sx+1,bin,i) = out((Y-1)/sy+1,(X-1)/sx+1,bin,i) - 1;
                end
            end
            for x=max(1,X-n):min(width,X+n)
                for y=Y+n-sy+1:min(height,Y+n)
                    hue = image(y,x,i);
                    bin = (hue+1)/w;
                    out((Y-1)/sy+1,(X-1)/sx+1,bin,i) = out((Y-1)/sy+1,(X-1)/sx+1,bin,i) + 1;
                end
            end
        end
    end
end

for i = 1:3
    for X=1:sx:width
        for Y=1:sy:height
            count = (min(width,X+n) - max(1,X-n))*(min(height,Y+n) - max(1,Y-n));
            out((Y-1)/sy+1,(X-1)/sx+1,:,i) = out((Y-1)/sy+1,(X-1)/sx+1,:,i)/count;
        end
    end
end

% Complexity: 3(height/sy)[(width/sx)*(4*n*sy) + 2n^2]
% Complexity Normalization:  (height/sy)(width/sx)(256/w)

end