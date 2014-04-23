function [ gradientImages ] = readAndFilterVideo(name, centroids)
%   Function: readAndFilterVideo
%   Author : Stephen Lazzaro
%   Description: Takes the input centroids and places them in the
%   appropriate frame.  Then, uses optical flow (with a texture filter) in
%   order to track and move the centroid i.e. track the important object.
%   Optical flow is used to find an image of gradients for all of the
%   pixels in a particular frame, and then the gradient at the pixel where
%   each centroid is located is used to shift the centroid, hence tracking
%   an object.
%
%   PARAMETERS:
%       name: name of the video file
%       centroids: n x 3 matrix where n is the number of centroids that the
%           user wants to be tracked.  The first column is the row of the centroid,
%           the second is its column, and the third is the frame where the centroid
%           should appear.  The order of the centroids should be from earliest
%           frame to latest frame.  NOTE: the centroids must be within
%           2 pixels of the bounds of the video

vidObj = VideoReader(name);

%optical flow code...default is Horn-Schunck...can also be adapted to work with a live feed
% the Horizontal component as the real part of the result, and the vertical 
% component as the complex part of the result.
% based off http://www.mathworks.com/help/imaq/examples/live-motion-detection-using-optical-flow.html
optical = vision.OpticalFlow( ...
'OutputValue', 'Horizontal and vertical components in complex form', ...
    'ReferenceFrameSource', 'Input Port');

hVideoIn = vision.VideoPlayer;
hVideoIn.Name  = 'Original Video';
hVideoOut = vision.VideoPlayer;
hVideoOut.Name  = 'Motion Detected Video';

% maxWidth = imaqhwinfo(vidDevice,'MaxWidth');
% maxHeight = imaqhwinfo(vidDevice,'MaxHeight');
maxWidth = vidObj.Width;
maxHeight = vidObj.Height;
shapes = vision.ShapeInserter;
shapes.Shape = 'Lines';
shapes.BorderColor = 'white';
r = 1:5:maxHeight;
c = 1:5:maxWidth;
[Y, X] = meshgrid(c,r);

%NOTE: SHOULD GO TO UP TO NUM OF FRAMES - 1
frame = 1;
rgbData = read(vidObj, frame);
nframes = vidObj.NumberOfFrames;
batchDivider = 50;
numCentroidsShowing = 0;
numCentroidsUnused = size(centroids,1);
for i = 1:batchDivider
    start = ceil( (i - 1) * nframes/batchDivider);
    finish = ceil( i * (nframes - 1) / batchDivider);
    theSize = ceil(nframes / batchDivider);
    gradientImages = zeros(maxHeight, maxWidth, 3, theSize);
    for k = start:finish
        % First check if new centroids should be added to frame
        % NOTE: centroids should be in order from earliest to latest frame
        if (numCentroidsUnused ~= 0)
            for index = 1:size(centroids,1)
                if numCentroidsUnused == 0 %need this case for after the last centroid is removed
                    break;
                end
                currCentroid = centroids(index,:);
                if (currCentroid(3) == frame)
                    numCentroidsShowing = numCentroidsShowing + 1;
                    numCentroidsUnused = numCentroidsUnused - 1;
                    centroidsShowing(numCentroidsShowing,:) = currCentroid;
                else
                    centroids = centroids(index:size(centroids,1),:);
                    break;
                end
            end
        end
        
        % Acquire single frame
        rgbData2 = read(vidObj, frame + 1);
        gray1 = rgb2gray(rgbData);
        gray2 = rgb2gray(rgbData2);
        
        % Compute the optical flow for that particular frame...use texture
        % filter beforehand
        optFlow = step(optical, double(rangefilt(gray2)), double(rangefilt(gray1)));
        
        % Downsample optical flow field.
        optFlow_DS = optFlow(r, c);
        H = imag(optFlow_DS)*50;
        V = real(optFlow_DS)*50;
        
        % Draw lines on top of image
        %lines = [Y(:)'; X(:)'; Y(:)'+V(:)'; X(:)'+H(:)'];
        %rgb_Out = step(shapes, double(rangefilt(gray2)),  lines');
        
        %Allow this for centroid to be displayed
        if (numCentroidsShowing ~= 0)
            for q = 1:size(centroidsShowing,1)
                %c = floor(fliplr(c));
                %display(c);
                c = centroidsShowing(q,:);
                c = floor(c);
                width = 2;
                row = c(1)-width:c(1)+width;
                col = c(2)-width:c(2)+width;
                rgbData(row,col,1) = 255;
                rgbData(row,col,2) = 0;
                rgbData(row,col,3) = 0;
            end
        end
        
        % Send image data to video player
        % Display original video with centroids added
        step(hVideoIn, rgbData);
        
        % Display video along with motion vectors.
        %step(hVideoOut, rgb_Out);
        
        % Increment frame count
        rgbData = rgbData2; %do this so you don't have to read each file on two iterations
        frame = frame + 1;
        
        % Finally, shift each of centroidsShowing based on optical
        %flow field.  Note: if the centroid has any coordinate out of
        %bounds then remove it from the centroidsShowingArray and decrement
        %the numCentroidsShowing count
        if numCentroidsShowing ~= 0
            numOfRowsToBeRemoved = 0;
            for q = 1:size(centroidsShowing,1)
                c = centroidsShowing(q,:);
                complexNum = optFlow(floor(c(1)), floor(c(2)));
                horizComp = real(complexNum);
                verticalComp = imag(complexNum);
                centroidsShowing(q,1) = c(1) + horizComp;
                centroidsShowing(q,2) = c(2) + verticalComp;
                %now check if any of the centroids are out of the views
                %bounds.  If so, then add it to the list of rows that will
                %be removed
                if (centroidsShowing(q,1) < 1) || (centroidsShowing(q,1) > maxHeight) || ...
                    (centroidsShowing(q,2) < 1) || (centroidsShowing(q,2) > maxWidth)
                    numOfRowsToBeRemoved = numOfRowsToBeRemoved + 1;
                    rowsToRemove(numOfRowsToBeRemoved) = q;
                end
            end
            if numOfRowsToBeRemoved ~= 0
                centroidsShowing = removerows(centroidsShowing, 'ind', rowsToRemove);
            end
        end
    end
end

%frameRate = get(vidObj,'FrameRate');
%implay(taggedObjs,frameRate);


% http://www.mathworks.com/products/computer-vision/code-examples.html;jsessionid=388379f445f6563bd4c454e94d72?file=/products/demos/shipping/vision/videotrafficof.html



%texture stuff
% http://www.mathworks.com/help/images/examples/texture-segmentation-using-texture-filters.html

end

