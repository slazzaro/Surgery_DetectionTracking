function [ output ] = readAndFilterVideo(name, filterVal, frameToFilter, shouldShowDark)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%opticalFlow = vision.OpticalFlow

vidObj = VideoReader(name);
veins = rgb2gray(read(vidObj,frameToFilter));

%veins = edge(veins, 'canny'); %good ones are canny, log and zerocross
veins = rangefilt(veins); %texture filter
figure, imshow(veins)

if shouldShowDark == 1
    noDarkObjs = imextendedmin(veins,filterVal);
else
    noDarkObjs = imextendedmax(veins,filterVal);
end

figure, imshow(noDarkObjs)
sedisk = strel('disk',2);
noSmallStructures = imopen(noDarkObjs, sedisk);
imshow(noSmallStructures)


%this code based on 
% http://www.mathworks.com/help/images/examples/detecting-cars-in-a-video-of-traffic.html

nframes = get(vidObj, 'NumberOfFrames');
I = read(vidObj, 1);
%NOTE MUST BE DONE IN BATCHES SO MATLAB DOESN'T RUN OUT OF MEMORY
batchDivider = 50;
sedisk = strel('disk',5);
for i = 1:batchDivider
    start = ceil( (i - 1) * nframes/batchDivider);
    finish = ceil( i * nframes / batchDivider);
    theSize = ceil(nframes / batchDivider);
    taggedObjs = zeros([size(I,1) size(I,2) 3 theSize], class(I));
    display(strcat('INFO ---- starting at frame:', num2str(start)));
    for k = start : finish
        singleFrame = read(vidObj, k + 1);
        
        % Convert to grayscale to do morphological processing.
        I = rgb2gray(singleFrame);
        
        % Remove dark cars.
        if shouldShowDark == 1
            noDarkObjs = imextendedmin(I,filterVal);
        else
            noDarkObjs = imextendedmax(I,filterVal);
        end
        
        % Remove lane markings and other non-disk shaped structures.
        noSmallStructures = imopen(noDarkObjs, sedisk);
        
        % Remove small structures.
        noSmallStructures = bwareaopen(noSmallStructures, 100);
        
        % Get the area and centroid of each remaining object in the frame. The
        % object with the largest area is the light-colored car.  Create a copy
        % of the original frame and tag the car by changing the centroid pixel
        % value to red.
        index = k - start + 1;
        
        %Allow this for centroid
        %taggedObjs(:,:,:,index) = singleFrame;
        
        %allow this when using bounding box
        taggedObjs(:,:,:,index) = singleFrame;
        I = taggedObjs(:,:,:,index);
        
        stats = regionprops(noSmallStructures, {'Centroid','Area', 'BoundingBox'});
        if ~isempty([stats.Area])
            areaArray = [stats.Area];
            [junk,idx] = max(areaArray);
            
            %Allow this for centroid
            c = stats(idx).Centroid;
            c = floor(fliplr(c));
            width = 2;
            row = c(1)-width:c(1)+width;
            col = c(2)-width:c(2)+width;
            taggedObjs(row,col,1,index) = 255;
            taggedObjs(row,col,2,index) = 0;
            taggedObjs(row,col,3,index) = 0;
            
            %% BOUNDING BOX rectangle drawing
%             bb = stats(idx).BoundingBox;
%             bb = floor(bb);
%             BBimg = false(bb([4 3]));
%             BBimg(:, [1 end]) = true;
%             BBimg([1 end],:) = true;
%             %taggedObjs(bb(2):(bb(2)+bb(4)),bb(1):(bb(1)+bb(3)),1,k) = double(BBimg).*255;
%             taggedObjs(bb(2):(bb(2)+bb(4)),bb(1):(bb(1)+bb(3)),1,index) = 255;
%             taggedObjs(bb(2):(bb(2)+bb(4)),bb(1):(bb(1)+bb(3)),2,index) = 165;
%             taggedObjs(bb(2):(bb(2)+bb(4)),bb(1):(bb(1)+bb(3)),3,index) = 0;
            
            %% BOUNDING BOX drawing
%             bb = stats(idx).BoundingBox;
%             bb = floor(bb);
%             BBimg = false(bb([4 3]));
%             BBimg(:, [1 end]) = true;
%             BBimg([1 end],:) = true;
%             M = false(size(I,1),size(I,2));
%             %M(bb(2):bb(2)+bb(4)+1,[bb(1), bb(1)+bb(3)+1]) = true;
%             %M([bb(2),bb(2)+bb(4)+1],bb(1):bb(1)+bb(3)+1) = true;
%             M(bb(2):bb(2)+bb(4)+1,bb(1),bb(1)+bb(3)+1) = true;
%             M(bb(2),bb(2)+bb(4)+1,bb(1):bb(1)+bb(3)+1) = true;
%             idx = find(M);
%             nM = numel(M);
%             I(idx) = 255;
%             I(idx+nM) = 165;
%             I(idx+nM*2) = 0;
%             taggedObjs(:,:,:,index) = I;
            
        end
    end
    
    frameRate = get(vidObj,'FrameRate');
    implay(taggedObjs,frameRate);
end


%optical flow code
optical = vision.OpticalFlow( ...
    'OutputValue', 'Horizontal and vertical components in complex form');

hVideoIn = vision.VideoPlayer;
hVideoIn.Name  = 'Original Video';
hVideoOut = vision.VideoPlayer;
hVideoOut.Name  = 'Motion Detected Video';

maxWidth = imaqhwinfo(vidDevice,'MaxWidth');
maxHeight = imaqhwinfo(vidDevice,'MaxHeight');
shapes = vision.ShapeInserter;
shapes.Shape = 'Lines';
shapes.BorderColor = 'white';
r = 1:5:maxHeight;
c = 1:5:maxWidth;
[Y, X] = meshgrid(c,r);


% Set up for stream
nframes = 0;
while (nframes<100)     % Process for the first 100 frames.
    % Acquire single frame from imaging device.
    rgbData = step(vidDevice);

    % Compute the optical flow for that particular frame.
    optFlow = step(optical,rgb2gray(rgbData));

    % Downsample optical flow field.
    optFlow_DS = optFlow(r, c);
    H = imag(optFlow_DS)*50;
    V = real(optFlow_DS)*50;

    % Draw lines on top of image
    lines = [Y(:)'; X(:)'; Y(:)'+V(:)'; X(:)'+H(:)'];
    rgb_Out = step(shapes, rgbData,  lines');

    % Send image data to video player
    % Display original video.
    step(hVideoIn, rgbData);
    % Display video along with motion vectors.
    step(hVideoOut, rgb_Out);

    % Increment frame count
    nframes = nframes + 1;
end

end

