function [ ] = ProcessVideoRealTime( video, trainingHistograms, s, widthOfBins, thresh, skip, numObjsToDetect )
% Processes the video passed in looking to
% classify the objects described in the trainingHistograms

%create video to be outputed
%vidOut = VideoWriter(strcat('../grayvid_window', num2str(windowSize),'_binwidth', num2str(widthOfBins)));
%vidOut.FrameRate = vidObj.FrameRate;

%TODO: insertText function matlab

hVideoIn = vision.VideoPlayer;
hVideoIn.Name  = 'Original Video';
hVideoOut = vision.VideoPlayer;
hVideoOut.Name  = 'Recognition Video';

batchSize = 20;
divider = floor(video.NumberOfFrames / batchSize);

%object which will keep track of the current circles on screen.  First
%column is x, second is y, and third is radius.  If no object detected on
%screen then x,y,radius will each be 0
circles = zeros(numObjsToDetect,3);
shouldCallDetector = 1;
%global T;

%open(vidOut);
for q = 1:divider
    startI = (q - 1) * batchSize;
    
    vidAll = zeros(video.Height, video.Width, 3, batchSize);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading video batch:', num2str(q)));
    for i =1:batchSize
        vidAll(:,:,:,i) = read(video,i+ startI);
    end
     
    if (shouldCallDetector == 1)
        shouldCallDetector = 0;
        T = timer('TimerFcn',@DetectObjectsInBackground, 'StopFcn', @UpdateShouldDetect, 'ErrorFcn', @ErrorFunc);
        start(T);
    end
    
    for c = 1:size(circles,1);
        if (circles(c,1) ~= 0)
            vidAll = AddCircleToVideo( vidAll, meanx, meany, radius, [0 0 0] );
        end
    end
    
    for i =1:batchSize
        % Display original video
        %step(hVideoIn, uint8(out(:,:,:,i)));
        
        % Display video with detection
        step(hVideoOut, uint8(vidAll(:,:,:,i)));
    end
    
    %writeVideo(vidOut, out);
    
    clear vidAll;
    clear out;
    clear componentVideo;
end

%close(vidOut);

%    outDir=strcat(trainDir,'/videoUpdated');
%    mkdir(outDir);
%    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));

    function DetectObjectsInBackground()
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Timer Fired'));
        componentVideo = VideoToScoreVideoSkip( double(vidAll), trainingHistograms, s, widthOfBins, thresh, skip);
        %display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Analyzing components...'));
        componentVideo = ScoreVideoToComponentVideo( componentVideo );
        [meanx, meany, radius] = uint8(GetCircleInfo(componentVideo,s));
        circles(1,1) = meanx;
        circles(1,2) = meany;
        circles(1,3) = radius;
    end

    function ErrorFunc()
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Timer Error'));
    end

    function UpdateShouldDetect()
        shouldCallDetector = 1;
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Timer Finished'));
    end

end
