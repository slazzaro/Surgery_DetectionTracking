function [ ] = ProcessVideoRealTimePar( video, trainingHistograms, s, thresh, numObjsToDetect, vidOutputName, folderNames )
% Processes the video passed in looking to
% classify the objects described in the trainingHistograms

%create video to be outputed
skip = round(floor(video.FrameRate) / 2);
vidOutputName = strcat(vidOutputName,'realtime_s',num2str(s),'_thresh',num2str(abs(thresh)),'_skip',num2str(skip));
vidOut = VideoWriter(vidOutputName);
vidOut.FrameRate = video.FrameRate;

hVideoOut = vision.VideoPlayer;
hVideoOut.Name  = 'Recognition Video';
hVideoOut.Position = [200 200 1300 800];

%good trackingThresh values: 500, 400...increase the decimal to allow bigger
%movement changes from frame to frame
trackingThreshold = 400;
zerosInARow = 0;
realValsInARow = 0;

batchSize = floor(video.FrameRate);
divider = floor(video.NumberOfFrames / batchSize);

%object which will keep track of the current circles on screen.  First
%column is x, second is y, and third is radius.  If no object detected on
%screen then x,y,radius will each be 0
circles = zeros(numObjsToDetect,3);
shouldCallDetector = 1;
%global T;

vidAll = zeros(video.Height, video.Width, 3, batchSize);
fBeenCalled = 0;

%p = gcp();
open(vidOut);
for q = 1:divider
    if (fBeenCalled == 1)
        display(f.State);
        if (strcmp(f.State, 'finished') == 1)
            [ circles, zerosInARow, realValsInARow, shouldCallDetector ] = fetchOutputs(f);
        end
    end
    startI = (q - 1) * batchSize;
    %display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading video batch:', num2str(q)));
    for i =1:batchSize
        vidAll(:,:,:,i) = read(video,i+ startI);
        for c = 1:numObjsToDetect
            if (circles(c,1) ~= 0)
                display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Adding Circle And Label:', num2str(q)));
                vidAll(:,:,:,i) = insertShape(vidAll(:,:,:,i), 'Circle', [circles(c,1) circles(c,2) circles(c,3)], 'Color', 'black');
                vidAll(:,:,:,i) = insertText(vidAll(:,:,:,i), ...
                    [circles(c,1), circles(c,2)], folderNames(1), ...
                    'TextColor', 'black', 'AnchorPoint', 'Center', 'BoxOpacity', 1);
            end
        end
%         step(hVideoOut, uint8(vidAll(:,:,:,i)));
        writeVideo(vidOut, uint8(vidAll(:,:,:,i)));
    end
    
    if (shouldCallDetector == 1)
        %must make copy? so that when vidAll is edited in next loop
        %iteration timer function doesn't use that edited potentially
        %incomplete vidAll
        
        vidAllCopy = vidAll;
        shouldCallDetector = 0;
        %f = parfeval(p, @DetectObjects, 4, vidAllCopy, trainingHistograms, s, thresh, skip, circles, zerosInARow, realValsInARow, trackingThreshold, batchSize);
        f = parfeval(@DetectObjects, 4, vidAllCopy, trainingHistograms, s, thresh, skip, circles, zerosInARow, realValsInARow, trackingThreshold, batchSize);
        fBeenCalled = 1;
    end
    
    clear vidAll;
    clear out;
    clear componentVideo;
end

close(vidOut);

end