function [ out ] = ProcessVideo( trainDir, video, trainingHistograms, widthOfBins )
% Processes the video passed in looking to
% classify the objects described in the trainingHistograms

out = 0;

vidObj = video;
threshold = size(trainingHistograms,3) / 10;
windowSize = 10;

%create video to be outputed
vidOut = VideoWriter(strcat('../grayvid_window', num2str(windowSize),'_binwidth', num2str(widthOfBins)));
vidOut.FrameRate = vidObj.FrameRate;

hVideoIn = vision.VideoPlayer;
hVideoIn.Name  = 'Detection Video';
hVideoOut = vision.VideoPlayer;
hVideoOut.Name  = 'Gray Scale Confidence Video';

% maxWidth = imaqhwinfo(vidDevice,'MaxWidth');
% maxHeight = imaqhwinfo(vidDevice,'MaxHeight');
maxWidth = vidObj.Width;
maxHeight = vidObj.Height;
shapes = vision.ShapeInserter;
shapes.Shape = 'Lines';
shapes.BorderColor = 'white';
%r = 1:5:maxHeight;
%c = 1:5:maxWidth;
%[Y, X] = meshgrid(c,r);

%NOTE: SHOULD GO TO UP TO NUM OF FRAMES - 1
% if testing,
%frame = 4769;
%for i = 18:batchDivider
%pix3 = [416 321 4984; 411 431 5157];
%pixSurg = [273 592 164]
frame = 1;
rgbData = read(vidObj, frame);
nframes = vidObj.NumberOfFrames;
batchDivider = 50;

open(vidOut);
for i = 1:batchDivider
    start = ceil( (i - 1) * nframes/batchDivider);
    display(strcat('INFO : Reading Video Frame:', num2str(start)));
    finish = min(ceil( i * nframes / batchDivider), nframes - 1);
    %theSize = ceil(nframes / batchDivider);
    
    for k = start:finish
        
        % Acquire single frame
        rgbData2 = read(vidObj, min(frame + 1, nframes));
        
        gray_Out = zeros(size(rgbData,1), size(rgbData,2));
        
        currFrameHist = Histograms1D( rgbData, windowSize, widthOfBins );
        
        % Now iterate through the currFrameHists looking for max score
        M = length(rgbData(:,1,1));
        N = length(rgbData(1,:,1));
        maxScore = 0;
        maxX = 0;
        maxY = 0;
        
        for X=1:N %X will control the x-coordinate of the central pixel
            for Y=1:M %Y will control the y-coordinate of the central pixel
                currHist = currFrameHist(Y,X,:,:); %third dimension is bins, 4th is the 3 colors
                %currHist may need to be reshaped here?
                score = Score1D(currHist, trainingHistograms);
                display(score);
                if score > maxScore
                    maxScore = score;
                    maxX = X;
                    maxY = Y;
                end
                % max possible score is number of training images so warp to
                % 0 255 by dividing by that score and then multiplying by
                % 255
                gray_Out(Y,X) = (score / size(trainingHistograms,3)) * 255;
            end
        end
        
        % Check if maxScore is above certain threshold and if yes, classify as
        % the object of interest and put centroid at Y, X THEN TRACK FOR NOW?
        
        display(maxScore);
        
        if maxScore > threshold
            %c = centroidsShowing(q,:);
            %c = floor(c);
            c = [maxY maxX];
            width = 4;
            row = c(1)-width:c(1)+width;
            row(:) = max(1, row(:));
            row(:) = min(maxHeight, row(:));
            row = unique(row);
            col = c(2)-width:c(2)+width;
            col(:) = max(1, col(:));
            col(:) = min(maxWidth, col(:));
            col = unique(col);
            rgbData(row,col,1) = 255;
            rgbData(row,col,2) = 0;
            rgbData(row,col,3) = 0;
        end
        
        % Send image data to video player
        % Display original video with centroids added
        step(hVideoIn, rgbData);
        
        % Display video with gray scale confidence
        step(hVideoOut, gray_Out);
        
        writeVideo(vidOut, gray_Out);
        
        % Increment frame count
        rgbData = rgbData2; %do this so you don't have to read each file on two iterations
        frame = frame + 1;
    end
end

close(vidOut);

%    outDir=strcat(trainDir,'/videoUpdated');
%    mkdir(outDir);
%    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));


end