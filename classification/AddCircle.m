function [ image ] = AddCircle( image, centerx, centery, r )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
height = length(image(:,1,1));
width = length(image(1,:,1));


for radius = r-0.5:0.1:r+0.5
    for theta = 0:.001:2*pi
        % CHECK FOR OUT OF BOUNDS!
        x = round(radius*cos(theta) + centerx);
        y = round(radius*sin(theta) + centery);
        if((y>1)&&(y<height)&&(x>1)&&(x<width))
            image(y,x,:) = 0;
        end
    end
end

end

