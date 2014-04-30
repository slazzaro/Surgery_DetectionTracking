function [ out, trainingHistograms ] = Main( trainDir, videoPath )
% Takes in a directory path to training images and
% path to video.  First reads in the training images
% (which are one directory below trainDir) and puts
% them in a 256/w x 3 x numTrainingImages matrix.  Then
% calls the ProcessVideo function to process the video
% and try to classify objects in the video
	
	widthOfBins = 2;
    out = 0;

	dirContents = dir(trainDir); % all dir contents
    subFolders=[dirContents(:).isdir]; % just subfolder
    folderNames = {dirContents(subFolders).name};    %subfolder names
    folderNames(ismember(folderNames,{'.','..'})) = []; %remove
    folderNames
    imgFiles = dir(strcat(trainDir, '/', folderNames{1}, '/', '*.jpg')); 
    
    
    %trainImgCount=0;
    trainingHistograms = zeros( 256/widthOfBins, 3, length(imgFiles) );
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing training images'));
    
    for i = 1:length(imgFiles);
    	currImage = imread(strcat(trainDir, '/',folderNames{1}, '/', imgFiles(i).name));
    	currHist = SimpleHist1D(currImage, widthOfBins);
    	trainingHistograms(:,:,i) = currHist(:,:);
    end
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing video'));
    
    video = VideoReader(videoPath);
    
    ProcessVideo(trainDir, video, trainingHistograms, widthOfBins);
    
    
    
%    outDir=strcat(trainDir,'/videoUpdated');
%    mkdir(outDir);
%    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));
    

end