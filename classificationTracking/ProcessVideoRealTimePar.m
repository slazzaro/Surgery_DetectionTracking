function [ ] = ProcessVideoRealTimePar( video, trainingHistograms, s, widthOfBins, thresh, numObjsToDetect, vidOutputName, folderNames )
% Processes the video passed in looking to
% classify the objects described in the trainingHistograms

hVideoOut = vision.VideoPlayer;
hVideoOut.Name  = 'Recognition Video';
hVideoOut.Position = [200 200 1300 800];

%good trackingThresh values: 500, 400...increase the decimal to allow bigger
%movement changes from frame to frame
trackingThreshold = 600;
zerosInARow = 0;
realValsInARow = 0;

%create video to be outputed
%skip = round(batchSize / 3);
skip = 1;
vidOutputName = strcat(vidOutputName,'Par_s',num2str(s),'_binwidth', ...
    num2str(widthOfBins),'_thresh',num2str(abs(thresh)),'_skip',num2str(skip));
vidOut = VideoWriter(vidOutputName);
vidOut.FrameRate = video.FrameRate;

%object which will keep track of the current circles on screen.  First
%column is x, second is y, and third is radius.  If no object detected on
%screen then x,y,radius will each be 0
circles = zeros(numObjsToDetect,5);
shouldCallDetector = 1;
%global T;

%x = mod(video.Width,s);
fBeenCalled = 0;

%p = gcp();
open(vidOut);
tic
for q = 1:video.NumberOfFrames
   % display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading video batch:', num2str(q)));
    
    rgbCurr = read(video,q);
    if (fBeenCalled == 1)
        for c = 1:numObjsToDetect
            %display(f.State);
            if (circles(c,1) == 0)
                if (strcmp(f.State, 'finished') == 1)
                    [ circles, zerosInARow, realValsInARow, shouldCallDetector ] = fetchOutputs(f);
                    if (circles(c,1) > video.Height || circles(c,2) > video.Width)
                        circles(c,1) = 0;
                        realValsInARow = 0;
                        zerosInARow = 0;
                    end
                    if (circles(c,1) ~= 0)
                        realValsInARow = 0;
                        zerosInARow = 0;
                        circles(c,4) = rgbCurr(circles(c,1), circles(c,2), 1);
                        circles(c,5) = rgbCurr(circles(c,1), circles(c,2), 2);
                        circles(c,6) = rgbCurr(circles(c,1), circles(c,2), 3);
                    end
                end
            end
        end
    end

    for c = 1:numObjsToDetect
        if (circles(c,1) ~= 0)
            %display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Adding Circle And Label:', num2str(q)));
            rgbDisplay = insertShape(rgbCurr, 'Circle', [circles(c,1) circles(c,2) circles(c,3)], 'Color', 'black');
            rgbDisplay = insertText(rgbDisplay, ...
                [circles(c,1), circles(c,2)], folderNames(1), ...
                'TextColor', 'black', 'AnchorPoint', 'Center', 'BoxOpacity', 1);
        else
            rgbDisplay = rgbCurr;
        end
    end
    %step(hVideoOut, uint8(rgbDisplay));
    writeVideo(vidOut, uint8(rgbDisplay));
    
    for c = 1:numObjsToDetect
        if (circles(c,1) ~= 0)
             % Good neighbor sizes...85,...good penalties 3.6
            %newCentroids = calcSimpleOpticalFlow(circles, rgbCurr, rgbOld, 45, 1000, 4, 0);
            % Good neighbor sizes...20,12,...good penalties 2...good
            % windowSizes 3,5...
            [newCentroids, zerosInARow] = calcSimpleOpticalFlowHists(circles, rgbCurr, trainingHistograms, 30, 3, widthOfBins, thresh, zerosInARow);
            for x = 1:size(circles,1)
                circles(x,1) = newCentroids(x,1);
                circles(x,2) = newCentroids(x,2);
                if (circles(x,1) == 0)
                    realValsInARow = 0;
                    zerosInARow = 0;
                end
            end
        end
    end
    
    if (shouldCallDetector == 1 && circles(c,1) == 0)
        shouldCallDetector = 0;
        %f = parfeval(p, @DetectObjects, 4, vidAllCopy, trainingHistograms, s, widthOfBins, thresh, skip, circles, zerosInARow, realValsInARow, trackingThreshold);
        %f = parfeval(@DetectObjects, 4, vidAll(:,:,:,frameToStartAt:batchSize), trainingHistograms, s, widthOfBins, thresh, skip, circles, zerosInARow, realValsInARow, trackingThreshold);
        f = parfeval(@DetectObjects, 4, rgbCurr, trainingHistograms, s, widthOfBins, thresh, skip, circles, zerosInARow, realValsInARow, trackingThreshold);
        fBeenCalled = 1;
    end
    
    rgbOld = rgbCurr;
    
    clear vidAll;
    clear out;
    clear componentVideo;
end

close(vidOut);
toc

end