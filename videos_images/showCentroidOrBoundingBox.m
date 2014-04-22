function [ output_args ] = showCentroidOrBoundingBox( name )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

vidObj = VideoReader(name);

%this code based on 
% http://www.mathworks.com/help/images/examples/detecting-cars-in-a-video-of-traffic.html
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/300675

nframes = get(vidObj, 'NumberOfFrames');
I = read(vidObj, 1);
%NOTE MUST BE DONE IN BATCHES SO MATLAB DOESN'T RUN OUT OF MEMORY
batchDivider = 50;
sedisk = strel('disk',5);
for i = 1:batchDivider
    start = ceil( (i - 1) * nframes/batchDivider);
    finish = ceil( i * nframes / batchDivider);
    theSize = ceil(nframes / batchDivider);
    taggedObjs = zeros([vidObj.Height vidObj.Width 3 theSize], class(I));
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
   
        taggedObjs(:,:,:,index) = singleFrame;
        
        %allow this when using bounding box
%         taggedObjs2(:,:,:,index) = singleFrame;
%         I = taggedObjs2(:,:,:,index);
        
        stats = regionprops(noSmallStructures, {'Area','Centroid', 'BoundingBox'});
        if ~isempty([stats.Area])
            areaArray = [stats.Area];
            [junk,idx] = max(areaArray);
             
             %Allow this for centroid to be displayed
            c = stats(idx).Centroid;
            display(c);
            c = floor(fliplr(c));
            display(c);
            width = 2;
            row = c(1)-width:c(1)+width;
            col = c(2)-width:c(2)+width;
            taggedObjs(row,col,1,index) = 255;
            taggedObjs(row,col,2,index) = 0;
            taggedObjs(row,col,3,index) = 0;
            
            %% BOUNDING BOX rectangle drawing
%             bb = stats(idx).BoundingBox;
%             bb = floor(bb);
%             firstTerm = max(bb(2),1);
%             secondTerm = max(bb(1),1);
%             BBimg = false(bb([4 3]));
%             BBimg(:, [1 end]) = true;
%             BBimg([1 end],:) = true;
%             %taggedObjs(bb(2):(bb(2)+bb(4)),bb(1):(bb(1)+bb(3)),1,k) = double(BBimg).*255;
%             taggedObjs(firstTerm:(bb(2)+bb(4)),secondTerm:(bb(1)+bb(3)),1,index) = 255;
%             taggedObjs(firstTerm:(bb(2)+bb(4)),secondTerm:(bb(1)+bb(3)),2,index) = 165;
%             taggedObjs(firstTerm:(bb(2)+bb(4)),secondTerm:(bb(1)+bb(3)),3,index) = 0;
            
            %% BOUNDING BOX drawing
%             bb = stats(idx).BoundingBox;
%             bb = floor(bb);
%             if (bb(1) == 0)
%                 bb(1) = 1;
%             end
%             if (bb(2) == 0)
%                 bb(2) = 1;
%             end
%             BBimg = false(bb([4 3]));
%             BBimg(:, [1 end]) = true;
%             BBimg([1 end],:) = true;
%             M = false(size(I,1),size(I,2));
%             M(bb(2):bb(2)+bb(4)+1,[bb(1), bb(1)+bb(3)+1]) = true;
%             M([bb(2),bb(2)+bb(4)+1],bb(1):bb(1)+bb(3)+1) = true;
%             idx = find(M);
%             nM = numel(M);
%             I(idx) = 255;
%             I(idx+nM) = 165;
%             I(idx+nM*2) = 0;
%             taggedObjs2(:,:,:,index) = I;
            
        end
    end
    
    frameRate = get(vidObj,'FrameRate');
    implay(taggedObjs,frameRate);
end

end

