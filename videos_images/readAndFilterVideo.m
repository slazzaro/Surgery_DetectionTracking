function [ gradientImages ] = readAndFilterVideo(name, filterVal, frameToFilter, shouldShowDark)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%opticalFlow = vision.OpticalFlow

vidObj = VideoReader(name);
% veins = rgb2gray(read(vidObj,frameToFilter));
% 
% %veins = edge(veins, 'canny'); %good ones are canny, log and zerocross
% veins = rangefilt(veins); %texture filter
% figure, imshow(veins)
% 
% if shouldShowDark == 1
%     noDarkObjs = imextendedmin(veins,filterVal);
% else
%     noDarkObjs = imextendedmax(veins,filterVal);
% end
% 
% figure, imshow(noDarkObjs)
% sedisk = strel('disk',2);
% noSmallStructures = imopen(noDarkObjs, sedisk);
% imshow(noSmallStructures)


%this code based on 
% http://www.mathworks.com/help/images/examples/detecting-cars-in-a-video-of-traffic.html
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/300675

nframes = get(vidObj, 'NumberOfFrames');
% I = read(vidObj, 1);
% %NOTE MUST BE DONE IN BATCHES SO MATLAB DOESN'T RUN OUT OF MEMORY
% batchDivider = 50;
% sedisk = strel('disk',5);
% for i = 1:batchDivider
%     start = ceil( (i - 1) * nframes/batchDivider);
%     finish = ceil( i * nframes / batchDivider);
%     theSize = ceil(nframes / batchDivider);
%     taggedObjs = zeros([vidObj.Height vidObj.Width 3 theSize], class(I));
%     display(strcat('INFO ---- starting at frame:', num2str(start)));
%     for k = start : finish
%         singleFrame = read(vidObj, k + 1);
%         
%         % Convert to grayscale to do morphological processing.
%         I = rgb2gray(singleFrame);
%         
%         % Remove dark cars.
%         if shouldShowDark == 1
%             noDarkObjs = imextendedmin(I,filterVal);
%         else
%             noDarkObjs = imextendedmax(I,filterVal);
%         end
%         
%         % Remove lane markings and other non-disk shaped structures.
%         noSmallStructures = imopen(noDarkObjs, sedisk);
%         
%         % Remove small structures.
%         noSmallStructures = bwareaopen(noSmallStructures, 100);
%         
%         % Get the area and centroid of each remaining object in the frame. The
%         % object with the largest area is the light-colored car.  Create a copy
%         % of the original frame and tag the car by changing the centroid pixel
%         % value to red.
%         index = k - start + 1;
%    
%         taggedObjs(:,:,:,index) = singleFrame;
%         
%         %allow this when using bounding box
% %         taggedObjs2(:,:,:,index) = singleFrame;
% %         I = taggedObjs2(:,:,:,index);
%         
%         stats = regionprops(noSmallStructures, {'Area','Centroid', 'BoundingBox'});
%         if ~isempty([stats.Area])
%             areaArray = [stats.Area];
%             [junk,idx] = max(areaArray);
%              
%              %Allow this for centroid to be displayed
%             c = stats(idx).Centroid;
%             display(c);
%             c = floor(fliplr(c));
%             display(c);
%             width = 2;
%             row = c(1)-width:c(1)+width;
%             col = c(2)-width:c(2)+width;
%             taggedObjs(row,col,1,index) = 255;
%             taggedObjs(row,col,2,index) = 0;
%             taggedObjs(row,col,3,index) = 0;
%             
%             %% BOUNDING BOX rectangle drawing
% %             bb = stats(idx).BoundingBox;
% %             bb = floor(bb);
% %             firstTerm = max(bb(2),1);
% %             secondTerm = max(bb(1),1);
% %             BBimg = false(bb([4 3]));
% %             BBimg(:, [1 end]) = true;
% %             BBimg([1 end],:) = true;
% %             %taggedObjs(bb(2):(bb(2)+bb(4)),bb(1):(bb(1)+bb(3)),1,k) = double(BBimg).*255;
% %             taggedObjs(firstTerm:(bb(2)+bb(4)),secondTerm:(bb(1)+bb(3)),1,index) = 255;
% %             taggedObjs(firstTerm:(bb(2)+bb(4)),secondTerm:(bb(1)+bb(3)),2,index) = 165;
% %             taggedObjs(firstTerm:(bb(2)+bb(4)),secondTerm:(bb(1)+bb(3)),3,index) = 0;
%             
%             %% BOUNDING BOX drawing
% %             bb = stats(idx).BoundingBox;
% %             bb = floor(bb);
% %             if (bb(1) == 0)
% %                 bb(1) = 1;
% %             end
% %             if (bb(2) == 0)
% %                 bb(2) = 1;
% %             end
% %             BBimg = false(bb([4 3]));
% %             BBimg(:, [1 end]) = true;
% %             BBimg([1 end],:) = true;
% %             M = false(size(I,1),size(I,2));
% %             M(bb(2):bb(2)+bb(4)+1,[bb(1), bb(1)+bb(3)+1]) = true;
% %             M([bb(2),bb(2)+bb(4)+1],bb(1):bb(1)+bb(3)+1) = true;
% %             idx = find(M);
% %             nM = numel(M);
% %             I(idx) = 255;
% %             I(idx+nM) = 165;
% %             I(idx+nM*2) = 0;
% %             taggedObjs2(:,:,:,index) = I;
%             
%         end
%     end
%     
%     frameRate = get(vidObj,'FrameRate');
%     implay(taggedObjs,frameRate);
% end


%optical flow code...default is Horn-Schunck...can also be adapted to work
%with a live feed
% http://www.mathworks.com/help/imaq/examples/live-motion-detection-using-optical-flow.html
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

% Set up for stream
frame = 1;
%NOTE: SHOULD GO TO UP TO NUM OF FRAMES - 1
rgbData = read(vidObj, frame);
while (frame<200)     % Process for the first 100 frames.
    % Acquire single frame from imaging device.
    rgbData2 = read(vidObj, frame + 1);

    % Compute the optical flow for that particular frame.
    optFlow = step(optical, double(rgb2gray(rgbData2)), double(rgb2gray(rgbData)));

    % Downsample optical flow field.
    optFlow_DS = optFlow(r, c);
    H = imag(optFlow_DS)*50;
    V = real(optFlow_DS)*50;

    % Draw lines on top of image
    lines = [Y(:)'; X(:)'; Y(:)'+V(:)'; X(:)'+H(:)'];
    rgb_Out = step(shapes, double(rgb2gray(rgbData2)),  lines');

    % Send image data to video player
    % Display original video.
    step(hVideoIn, rgbData);
    
    % Display video along with motion vectors.
    step(hVideoOut, rgb_Out);

    % Increment frame count
    frame = frame + 1;
    rgbData = rgbData2; %do this so you don't have to read each file on two iterations
end

    %frameRate = get(vidObj,'FrameRate');
    %implay(taggedObjs,frameRate);


% http://www.mathworks.com/products/computer-vision/code-examples.html;jsessionid=388379f445f6563bd4c454e94d72?file=/products/demos/shipping/vision/videotrafficof.html



%texture stuff
% http://www.mathworks.com/help/images/examples/texture-segmentation-using-texture-filters.html

end

