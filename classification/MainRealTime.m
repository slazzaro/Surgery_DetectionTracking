function [] = MainRealTime( trainDir, videoPath, vidOutputName, s, widthOfBins, thresh, skip )
% Takes in a directory path to training images and
% path to video.  First reads in the training images
% (which are one directory below trainDir) and puts
% them in a 256/w x 3 x numTrainingImages matrix.  Then
% calls the ProcessVideoRealTime function to process the video
% and try to classify objects in the video
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing training images...'));
    [trainingHistograms, folderNames] = BuildTrainingHistograms(trainDir, widthOfBins);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading video...'));
    video = VideoReader(videoPath);
    
    %TO PROCESS AND SHOW LIVE...HAS INTERFACE FOR TRACKING TO BE ADDED
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing video...'));
    numObjectsToDetect = 1;
    ProcessVideoRealTime( video, trainingHistograms, s, widthOfBins, thresh, skip, numObjectsToDetect, vidOutputName, folderNames );

% %code to test speed of video playing without processing
%     hVideoOut = vision.VideoPlayer;
%     hVideoOut.Name  = 'Original Video';
%     hVideoOut.Position = [200 200 1300 800];
%     video = VideoReader(videoPath);
%     for i = 1:video.NumberOfFrames
%         frame = read(video, i);
%         step(hVideoOut, frame);
%     end
    
end