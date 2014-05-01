function [ image ] = OutlinePixel2( image,s,i,j,height, width,up,right,down,left)
%  Replace the pixels forming an (s)x(s) box around the i,j s-pixel of the
%  image with black pixels.

i=i-1;
j=j-1;

if (i>0)
    if (not(up))
        for x = max(1,j*s-s/2):min(width,j*s+s/2)
            for color = 1:3
                image(i*s-s/2+1,x,color)=0;
                image(i*s-s/2,x,color)=0;
            end
        end
    end
end

if (i<height)
    if (not(down))
        for x = max(1,j*s-s/2):min(width,j*s+s/2)
            for color = 1:3
                image(i*s+s/2-1,x,color)=0;
                image(i*s+s/2,x,color)=0;
            end
        end
    end
end

if (j>0)
    if (not(left))
        for y = max(1,i*s-s/2):min(width,i*s+s/2)
            for color = 1:3
                image(y,j*s-s/2+1,color)=0;
                image(y,j*s-s/2,color)=0;
            end
        end
    end
end

if (j<width)
    if (not(right))
        for y = max(1,i*s-s/2):min(width,i*s+s/2)
            for color = 1:3
                image(y,j*s+s/2-1,color)=0;
                image(y,j*s+s/2,color)=0;
            end
        end
    end
end

end