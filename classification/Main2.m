function [] = Main2( trainDir, videoPath, vidOutputName, s, widthOfBins, thresh, skip )
% Takes in a directory path to training images and
% path to video.  First reads in the training images
% (which are one directory below trainDir) and puts
% them in a 256/w x 3 x numTrainingImages matrix.  Then
% calls the ProcessVideo function to process the video
% and try to classify objects in the video

%MAIN2 includes outlines of the object or grids on the object controlled
%inside OutlineRegion.m (look for the commented line)
    
    vidOutputName = strcat(vidOutputName,'_s',num2str(s),'_binwidth', ...
    num2str(widthOfBins),'_thresh',num2str(abs(thresh)),'_skip',num2str(skip));

    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing training images...'));
    [trainingHistograms, folderNames] = BuildTrainingHistograms(trainDir, widthOfBins);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading video...'));
    video = VideoReader(videoPath);
    %TO PROCESS AND SHOW LIVE...HAS INTERFACE FOR TRACKING TO BE ADDED
    %ProcessVideo(trainDir, video, trainingHistograms, widthOfBins);
    
    %create video to be outputed
    %vidOut = VideoWriter(strcat('../outlineVid_thresh', num2str(thresh),'_binwidth', num2str(widthOfBins)));
    vidOut = VideoWriter(vidOutputName);
    vidOut.FrameRate = video.FrameRate;
    
    batchSize = 15;
    divider = floor(video.NumberOfFrames / batchSize);
    %framesToSee = floor(video.NumberOfFrames / divider);
    %display(framesToSee);
    open(vidOut);
    for q = 1:divider
        start = (q - 1) * batchSize;
        
        vidAll = zeros(video.Height, video.Width, 3, batchSize);
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading video batch:', num2str(q)));
        for i =1:batchSize
            vidAll(:,:,:,i) = read(video,i+ start);
        end
        
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing video...'));
        componentVideo = VideoToScoreVideoSkip( double(vidAll), trainingHistograms, s, widthOfBins, thresh, skip);
        
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Analyzing components...'));
        [componentVideo, num] = ScoreVideoToComponentVideo( componentVideo );
        if (num ~= 0) 
            out = uint8(ComponentVideoToCircleVideo(vidAll,componentVideo,s));
        else
            out = vidAll;
        end
        %out = uint8(OutlineVideoComponent(double(vidAll),componentVideo));
        %implay(out);
        
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Writing to file...'));
        writeVideo(vidOut, out);
        clear vidAll;
        clear out;
        clear componentVideo;
    end
    close(vidOut);
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Complete'));
    
    
%    outDir=strcat(trainDir,'/videoUpdated');
%    mkdir(outDir);
%    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));
    

end