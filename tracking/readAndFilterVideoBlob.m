function [ gradientImages ] = readAndFilterVideoBlob(name, centroids)
%   Function: readAndFilterVideo
%   Author : Stephen Lazzaro
%   Description: Uses blob analysis to 
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

% The following is based off code from MathWorks that can be found on the
% webpage below.
% http://www.mathworks.com/products/computer-vision/code-examples.html;jsessionid=388379f445f6563bd4c454e94d72?file=/products/demos/shipping/vision/videotrafficof.html


%optical flow code...default is Horn-Schunck...can also be adapted to work with a live feed
% the Horizontal component as the real part of the result, and the vertical 
% component as the complex part of the result.
% based off http://www.mathworks.com/help/imaq/examples/live-motion-detection-using-optical-flow.html
optical = vision.OpticalFlow( ...
'OutputValue', 'Horizontal and vertical components in complex form', ...
    'ReferenceFrameSource', 'Input Port', 'Smoothness', 10);

hVideoIn = vision.VideoPlayer;
hVideoIn.Name  = 'Tracking Video';
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
% if testing,
%frame = 4769;
%for i = 18:batchDivider
%pix3 = [416 321 4984; 411 431 5157];
frame = 1;
rgbData = read(vidObj, frame);
nframes = vidObj.NumberOfFrames;
batchDivider = 50;
numCentroidsShowing = 0;
numCentroidsUnused = size(centroids,1);

%TESTT

sz = get(0,'ScreenSize');
pos = [20 sz(4)-300 200 200];
hVideo1 = vision.VideoPlayer('Name','Original Video','Position',pos);
pos(1) = pos(1)+220; % move the next viewer to the right
hVideo2 = vision.VideoPlayer('Name','Motion Vector','Position',pos);
pos(1) = pos(1)+220;
hVideo3 = vision.VideoPlayer('Name','Thresholded Video','Position',pos);
pos(1) = pos(1)+220;
hVideo4 = vision.VideoPlayer('Name','Results','Position',pos);

hMean1 = vision.Mean;
hMean2 = vision.Mean('RunningMean', true);
hMedianFilt = vision.MedianFilter;
hclose = vision.MorphologicalClose('Neighborhood', strel('line',5,45));
hblob = vision.BlobAnalysis(...
    'CentroidOutputPort', false, 'AreaOutputPort', true, ...
    'BoundingBoxOutputPort', true, 'OutputDataType', 'double', ...
    'MinimumBlobArea', 250, 'MaximumBlobArea', 3600, 'MaximumCount', 80);
herode = vision.MorphologicalErode('Neighborhood', strel('square',2));
hshapeins1 = vision.ShapeInserter('BorderColor', 'Custom', ...
                                  'CustomBorderColor', [0 1 0]);
hshapeins2 = vision.ShapeInserter( 'Shape','Lines', ...
                                   'BorderColor', 'Custom', ...
                                   'CustomBorderColor', [255 255 0]);
htextins = vision.TextInserter('Text', '%4d', 'Location',  [1 1], ...
                               'Color', [1 1 1], 'FontSize', 12);

% Initialize variables used in plotting motion vectors.
lineRow   =  22;
firstTime = true;
motionVecGain  = 20;
borderOffset   = 5;
decimFactorRow = 5;
decimFactorCol = 5;
                               
%END TEST


for i = 1:batchDivider
    start = ceil( (i - 1) * nframes/batchDivider);
    display(strcat('INFO : Reading Video Frame:', num2str(start)));
    finish = min(ceil( i * nframes / batchDivider), nframes - 1);
    theSize = ceil(nframes / batchDivider);
    gradientImages = zeros(maxHeight, maxWidth, 3, theSize);
    for k = start:finish
        % First check if new centroids should be added to frame
        % NOTE: centroids should be in order from earliest to latest frame
%         if (numCentroidsUnused ~= 0)
%             for index = 1:size(centroids,1)
%                 if numCentroidsUnused == 0 %need this case for after the last centroid is removed
%                     break;
%                 end
%                 currCentroid = centroids(index,:);
%                 if (currCentroid(3) == frame)
%                     numCentroidsShowing = numCentroidsShowing + 1;
%                     numCentroidsUnused = numCentroidsUnused - 1;
%                     centroidsShowing(numCentroidsShowing,1) = currCentroid(1);
%                     centroidsShowing(numCentroidsShowing,2) = currCentroid(2);
%                     %store the original color as well
%                     centroidsShowing(numCentroidsShowing,3) = rgbData(currCentroid(1),currCentroid(2),1);
%                     centroidsShowing(numCentroidsShowing,4) = rgbData(currCentroid(1),currCentroid(2),2);
%                     centroidsShowing(numCentroidsShowing,5) = rgbData(currCentroid(1),currCentroid(2),3);
%                 else
%                     centroids = centroids(index:size(centroids,1),:);
%                     break;
%                 end
%             end
%         end
        
        % Acquire single frame
        rgbData2 = read(vidObj, min(frame + 1, nframes));
        gray1 = rgb2gray(rgbData);
        gray2 = rgb2gray(rgbData2);
        
        % Compute the optical flow for that particular frame...the first
        % line uses a texture filter beforehand, the second does not
        %optFlow = step(optical, double(rangefilt(gray2)), double(rangefilt(gray1)));
        optFlow = step(optical, double(gray2), double(gray1));
        
        %TESTTTTTTTTT
        
        y1 = optFlow .* conj(optFlow);
        % Compute the velocity threshold from the matrix of complex velocities.
        vel_th = 0.5 * step(hMean2, step(hMean1, y1));
        
        % Threshold the image and then filter it to remove speckle noise.
        segmentedObjects = step(hMedianFilt, y1 >= vel_th);
        
        % Thin-out the parts of the road and fill holes in the blobs.
        segmentedObjects = step(hclose, step(herode, segmentedObjects));
        
        % Estimate the area and bounding box of the blobs.
        [area, bbox] = step(hblob, segmentedObjects);
        % Select boxes inside ROI (below white line).
        Idx = bbox(:,1) > lineRow;
        
        % Based on blob sizes, filter out objects which can not be cars.
        % When the ratio between the area of the blob and the area of the
        % bounding box is above 0.4 (40%), classify it as a car.
        ratio = zeros(length(Idx), 1);
        ratio(Idx) = single(area(Idx,1))./single(bbox(Idx,3).*bbox(Idx,4));
        ratiob = ratio > 0.3;
        count = int32(sum(ratiob));    % Number of cars
        bbox(~ratiob, :) = int32(-1);
        
        % Draw bounding boxes around the tracked cars.
        y2 = step(hshapeins1, rgbData, bbox);
        
        % Display the number of cars tracked and a white line showing the ROI.
        y2(22:23,:,:)   = 1;   % The white line.
        y2(1:15,1:30,:) = 0;   % Background for displaying count
        result = step(htextins, y2, count);
        
        % Generate coordinates for plotting motion vectors.
        if firstTime
            [R C] = size(optFlow);            % Height and width in pixels
            RV = borderOffset:decimFactorRow:(R-borderOffset);
            CV = borderOffset:decimFactorCol:(C-borderOffset);
            [Y X] = meshgrid(CV,RV);
            firstTime = false;
        end
        
        % Calculate and draw the motion vectors.
        tmp = optFlow(RV,CV) .* motionVecGain;
        lines = [Y(:), X(:), Y(:) + real(tmp(:)), X(:) + imag(tmp(:))];
        motionVectors = step(hshapeins2, single(rgbData), lines);
        
        % Display the results
        %step(hVideo1, rgbData);            % Original video
        step(hVideo2, motionVectors);    % Video with motion vectors
        %step(hVideo3, segmentedObjects); % Thresholded video
        step(hVideo4, result);           % Video with bounding boxes
        
        %END TESTTT
        
%         % Downsample optical flow field.
%         optFlow_DS = optFlow(r, c);
%         H = imag(optFlow_DS)*50;
%         V = real(optFlow_DS)*50;
%         
%         % Draw lines on top of image
%         %lines = [Y(:)'; X(:)'; Y(:)'+V(:)'; X(:)'+H(:)'];
%         lines = [Y(:)'; X(:)'; Y(:)'; X(:)'];
%         rgb_Out = step(shapes, double(rangefilt(gray2)),  lines');
        
        %Allow this for centroid to be displayed
%         if (numCentroidsShowing ~= 0)
%             for q = 1:size(centroidsShowing,1)
%                 %c = floor(fliplr(c));
%                 c = centroidsShowing(q,:);
%                 c = floor(c);
%                 width = 2;
%                 row = c(1)-width:c(1)+width;
%                 row(:) = max(1, row(:));
%                 row(:) = min(maxHeight, row(:));
%                 row = unique(row);
%                 col = c(2)-width:c(2)+width;
%                 col(:) = max(1, col(:));
%                 col(:) = min(maxWidth, col(:));
%                 col = unique(col);
%                 rgbData(row,col,1) = 255;
%                 rgbData(row,col,2) = 0;
%                 rgbData(row,col,3) = 0;
%             end
%         end
        
        % Send image data to video player
        % Display original video with centroids added
        %step(hVideoIn, rgbData);
        
        % Display video along with motion vectors.
        %step(hVideoOut, rgb_Out);
        
        % Increment frame count
        %rgbData = rgbData2; %do this so you don't have to read each file on two iterations
        frame = frame + 1;
        rgbData = read(vidObj, frame);
        
        % Finally, shift each of centroidsShowing based on optical
        %flow field.  Note: if the centroid has any coordinate out of
        %bounds then remove it from the centroidsShowingArray and decrement
        %the numCentroidsShowing count
%         if numCentroidsShowing ~= 0
%             numOfRowsToBeRemoved = 0;
%             for q = 1:size(centroidsShowing,1)
%                 c = centroidsShowing(q,:);
%                 complexNum = optFlow(floor(c(1)), floor(c(2)));
%                 horizComp = real(complexNum);
%                 verticalComp = imag(complexNum);
%                 centroidsShowing(q,1) = c(1) + verticalComp;
%                 centroidsShowing(q,2) = c(2) + horizComp;
%                 %now check if any of the centroids are out of the views
%                 %bounds.  If so, then add it to the list of rows that will
%                 %be removed
%                 if (centroidsShowing(q,1) < 1) || (centroidsShowing(q,1) > maxHeight) || ...
%                     (centroidsShowing(q,2) < 1) || (centroidsShowing(q,2) > maxWidth)
%                     numOfRowsToBeRemoved = numOfRowsToBeRemoved + 1;
%                     rowsToRemove(numOfRowsToBeRemoved) = q;
%                 end
%             end
%             if numOfRowsToBeRemoved ~= 0
%                 centroidsShowing = removerows(centroidsShowing, 'ind', rowsToRemove);
%                 numCentroidsShowing = numCentroidsShowing - numOfRowsToBeRemoved;
%                 clear rowsToRemove;
%             end
%         end
    end
end
display('TRACKING COMPLETE');
%frameRate = get(vidObj,'FrameRate');
%implay(taggedObjs,frameRate);

end

