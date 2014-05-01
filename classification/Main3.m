function [ out ] = Main3( trainDir, videoPath, n, s, widthOfBins, thresh )
% Takes in a directory path to training images and
% path to video.  First reads in the training images
% (which are one directory below trainDir) and puts
% them in a 256/w x 3 x numTrainingImages matrix.  Then
% calls the ProcessVideo function to process the video
% and try to classify objects in the video
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing training images...'));
    trainingHistograms = BuildTrainingHistograms(trainDir, widthOfBins);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading video...'));
    video = VideoReader(videoPath);
    %TO PROCESS AND SHOW LIVE...HAS INTERFACE FOR TRACKING TO BE ADDED
    %ProcessVideo(trainDir, video, trainingHistograms, widthOfBins);
    image = double(read(video,1));
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing image...'));
	componentImage = ImageToScoreArray( image, trainingHistograms, n, s, widthOfBins, thresh );
    imshow(componentImage);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Analyzing components...'));
    %componentImage = ScoreVideoToComponentVideo( componentVideo );
    %out = OutlineVideoComponent(double(vidAll),componentVideo);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Complete'));
    
    out=0;
%    outDir=strcat(trainDir,'/videoUpdated');
%    mkdir(outDir);
%    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));
    

end