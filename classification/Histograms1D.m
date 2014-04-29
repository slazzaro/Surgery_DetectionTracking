function [ out ] = Histograms1D( image, n, w )
%  Create for each pixel three 1D histograms of color intensity in a 2n by
%  2n window around that pixel.  image is a NxNx3 matrix of integers
%  [0,255].  w must divide 256.
M = length(image(:,1,1));
N = length(image(1,:,1));
out = zeros(M,N,256/w,3);

for i = 1:3 %i will control the color (R,G,B)
    for X=1:N %X will control the x-coordinate of the central pixel
        for Y=1:M %Y will control the y-coordinate of the central pixel
            temp = 0;
            for x=max(1,X-n):min(N,X+n)
                for y=max(1,Y-n):min(M,Y+n)
                    hue = image(y,x,i);
                    bin = floor(hue/w)+1;
                    out(Y,X,bin,i) = out(Y,X,bin,i) + 1;
                    temp = temp+1;
                end
            end
            out(Y,X,:,i) = out(Y,X,:,i)/temp;
        end
    end
end

% Complexity: 3MN(n^2)

end