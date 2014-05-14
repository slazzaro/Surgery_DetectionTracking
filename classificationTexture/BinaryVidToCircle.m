function [ meanx, meany, radius ] = BinaryVidToCircle( binary, s )
%[ meanx, meany, radius ] = BinaryToCircle( binary, s )
%   Detailed explanation goes here

count=0;
meanx=0;
meany=0;

for k=1:length(binary(1,1,:))
    for i=1:length(binary(:,1,1))
        for j=1:length(binary(1,:, 1))
            if (binary(i,j,k))
                meanx = meanx + (j-1)*s + s/2;
                meany = meany + (i-1)*s + s/2;
                count = count+1;
            end
        end
    end
end

meanx = meanx/count;
meany = meany/count;
divider = count / length(binary(1,1,:));
radius = (0.5)*s*sqrt(divider*pi);

end

