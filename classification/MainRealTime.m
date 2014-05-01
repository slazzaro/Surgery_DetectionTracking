function [] = MainRealTime( trainDir, videoPath, vidOutputName, s, widthOfBins, thresh, skip )
% Takes in a directory path to training images and
% path to video.  First reads in the training images
% (which are one directory below trainDir) and puts
% them in a 256/w x 3 x numTrainingImages matrix.  Then
% calls the ProcessVideo function to process the video
% and try to classify objects in the video

%MAIN2 includes outlines of the object or grids on the object controlled
%inside OutlineRegion.m (look for the commented line)
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing training images...'));
    trainingHistograms = BuildTrainingHistograms(trainDir, widthOfBins);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading video...'));
    video = VideoReader(videoPath);
    
    %TO PROCESS AND SHOW LIVE...HAS INTERFACE FOR TRACKING TO BE ADDED
    numObjectsToDetect = 1;
    ProcessVideoRealTime( video, trainingHistograms, s, widthOfBins, thresh, skip, numObjectsToDetect ) 

end