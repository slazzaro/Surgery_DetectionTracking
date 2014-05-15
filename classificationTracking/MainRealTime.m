function [] = MainRealTime( trainDir, videoPath, vidOutputName, s, widthOfBins, thresh, par )
% Takes in a directory path to training images and
% path to video.  First reads in the training images
% (which are one directory below trainDir) and puts
% them in a 256/w x 3 x numTrainingImages matrix.  Then
% calls the ProcessVideoRealTime function to process the video
% and try to classify objects in the video
% par is 1 if want to use parallel pool, 0 for timer
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing training images...'));
    [trainingHistograms, folderNames] = BuildTrainingHistograms(trainDir, widthOfBins);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading video...'));
    video = VideoReader(videoPath);
    
    %TO PROCESS AND SHOW LIVE...HAS INTERFACE FOR TRACKING TO BE ADDED
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing video...'));
    numObjectsToDetect = 1;
    if (par == 1)
        ProcessVideoRealTimePar( video, trainingHistograms, s, widthOfBins, thresh, numObjectsToDetect, vidOutputName, folderNames );
    else
        ProcessVideoRealTime( video, trainingHistograms, s, widthOfBins, thresh, numObjectsToDetect, vidOutputName, folderNames );
    end


% %code to test speed of video playing without processing
%     tic
%     %vidOutputName = strcat(vidOutputName,'realtime_s',num2str(s),'_binwidth', ...
%     %       num2str(widthOfBins),'_thresh',num2str(abs(thresh)));
%     %vidOut = VideoWriter(vidOutputName);
%     %vidOut.FrameRate = video.FrameRate;
%     
%     hVideoOut = vision.VideoPlayer;
%     hVideoOut.Name  = 'Original Video';
%     hVideoOut.Position = [200 200 1300 800];
%     video = VideoReader(videoPath);
%     %open(vidOut);
%     for i = 1:video.NumberOfFrames
%         frame = read(video, i);
%         step(hVideoOut, frame);
%         %writeVideo(vidOut, frame);
%     end
%     %close(vidOut);
%     toc
    
end