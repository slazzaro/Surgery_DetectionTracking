function [ ] = ProcessVideoRealTime( video, trainingHistograms, s, widthOfBins, thresh, skip, numObjsToDetect, vidOutputName, folderNames )
% Processes the video passed in looking to
% classify the objects described in the trainingHistograms

%create video to be outputed
vidOutputName = strcat(vidOutputName,'realtime_s',num2str(s),'_binwidth', ...
    num2str(widthOfBins),'_thresh',num2str(abs(thresh)),'_skip',num2str(skip));
vidOut = VideoWriter(vidOutputName);
vidOut.FrameRate = video.FrameRate;

hVideoIn = vision.VideoPlayer;
hVideoIn.Name  = 'Original Video';
hVideoOut = vision.VideoPlayer;
hVideoOut.Name  = 'Recognition Video';

trackingThreshold = 0.05 * (video.Width * video.Height);
zerosInARow = 0;
realValsInARow = 0;

batchSize = 10;
divider = floor(video.NumberOfFrames / batchSize);

%object which will keep track of the current circles on screen.  First
%column is x, second is y, and third is radius.  If no object detected on
%screen then x,y,radius will each be 0
circles = zeros(numObjsToDetect,3);
shouldCallDetector = 1;
%global T;

open(vidOut);
for q = 1:divider
    startI = (q - 1) * batchSize;
    
    vidAll = zeros(video.Height, video.Width, 3, batchSize);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading video batch:', num2str(q)));
    for i =1:batchSize
        vidAll(:,:,:,i) = read(video,i+ startI);
        for c = 1:size(circles,1);
            if (circles(c,1) ~= 0)
                display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Adding Circle:', num2str(q)));
                %display(circles);
                vidAll(:,:,:,i) = AddCircleToImage( vidAll(:,:,:,i), circles(c,1), circles(c,2), circles(c,3), [0 0 0] );
                vidAll(:,:,:,i) = insertText(vidAll(:,:,:,i), ...
                    [circles(c,1), circles(c,2)], folderNames(1), ...
                    'TextColor', 'black', 'AnchorPoint', 'Center');
            end
        end
        %step(hVideoOut, uint8(vidAll(:,:,:,i)));
        writeVideo(vidOut, uint8(vidAll(:,:,:,i)));
    end
    
    if (shouldCallDetector == 1)
        %must make copy so that when vidAll is edited in next loop
        %iteration timer function doesn't use that edited potentially
        %incomplete vidAll
        vidAllCopy = vidAll;
        shouldCallDetector = 0;
        T = timer('TimerFcn',@(~,~)DetectObjectsInBackground, ...
            'StopFcn', @(~,~)UpdateShouldDetect, 'ErrorFcn', @(~,~)ErrorFunc);
        start(T);
    end
    
    clear vidAll;
    clear out;
    clear componentVideo;
end

close(vidOut);

%    outDir=strcat(trainDir,'/videoUpdated');
%    mkdir(outDir);
%    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));

    function DetectObjectsInBackground
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Timer Fired'));
        componentVideo = VideoToScoreVideoSkip( double(vidAllCopy), trainingHistograms, s, widthOfBins, thresh, skip);
        [componentVideo, num] = ScoreVideoToComponentVideo( componentVideo );
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Timer Will Look For Mean and Radius'));
        if (num ~= 0)
            [meanxNew, meanyNew, radiusNew] = GetCircleInfo(componentVideo,s);
            if (circles(1,1) ~= 0)
                if (meanxNew == 0)
                    zerosInARow = zerosInARow + 1;
                    realValsInARow = 0;
                end
                if (zerosInARow >= 2) %if 2 zeros in a row, then conclude it's off screen
                    circles(1,1) = meanxNew;
                    circles(1,2) = meanyNew;
                    circles(1,3) = radiusNew;
                else
                    %To make sure noise wasn't captured only take small changes in
                    %obj position
                    if ( norm(circles(1,1:2) - [meanxNew, meanyNew] ) ^2 < trackingThreshold )
                        circles(1,1) = meanxNew;
                        circles(1,2) = meanyNew;
                        circles(1,3) = radiusNew;
                        zerosInARow = 0;
                    end
                end
            else
                %if object hasn't yet been detected, then set it to new
                %detection as long as been detected twice in a row
                realValsInARow = realValsInARow + 1;
                zerosInARow = 0;
                if (realValsInARow >= 3)
                    circles(1,1) = meanxNew;
                    circles(1,2) = meanyNew;
                    circles(1,3) = radiusNew;
                end
            end
            display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Timer Finished Detection'));
        else
            zerosInARow = zerosInARow + 1;
            realValsInARow = 0;
            if (zerosInARow >= 2) %if 2 zeros in a row, then conclude it's off screen
                circles(1,1) = 0;
                circles(1,2) = 0;
                circles(1,3) = 0;
            end
        end
    end

    function ErrorFunc
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Timer Error'));
    end

    function UpdateShouldDetect
        shouldCallDetector = 1;
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Timer Finished Stop Function'));
    end

end
