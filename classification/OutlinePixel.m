function [ image ] = OutlinePixel( image, s, i, j, height, width )
%  Replace the pixels forming an (s)x(s) box around the i,j s-pixel of the
%  image with black pixels.

i=i-1;
j=j-1;

if (i>0)
    for x = max(1,j*s-s/2+1):min(width,j*s+s/2-1)
        for color = 1:3
            image(i*s-s/2+1,x,color)=0;
        end
    end
end

if (i<height)
    for x = max(1,j*s-s/2+1):min(width,j*s+s/2-1)
        for color = 1:3
            image(i*s+s/2-1,x,color)=0;
        end
    end
end

if (j>0)
    for y = max(1,i*s-s/2+1):min(width,i*s+s/2-1)
        for color = 1:3
            image(y,j*s-s/2+1,color)=0;
        end
    end
end

if (j<width)
    for y = max(1,i*s-s/2+1):min(width,i*s+s/2-1)
        for color = 1:3
            image(y,j*s+s/2-1,color)=0;
        end
    end
end

end

