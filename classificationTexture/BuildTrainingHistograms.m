function [ trainingHistograms, folderNames ] = BuildTrainingHistograms( trainDir )
    
    dirContents = dir(trainDir); % all dir contents
    subFolders=[dirContents(:).isdir]; % just subfolder
    folderNames = {dirContents(subFolders).name};    %subfolder names
    folderNames(ismember(folderNames,{'.','..'})) = []; %remove
    imgFiles = dir(strcat(trainDir, '/', folderNames{1}, '/', '*.jpg')); 
    
    trainingHistograms = zeros( 8, 8, length(imgFiles) );
    
    for i = 1:length(imgFiles);
        currImage = imread(strcat(trainDir, '/',folderNames{1}, '/', imgFiles(i).name));
    	currHist = SimpleHist1D(currImage);
    	trainingHistograms(:,:,i) = currHist(:,:);
    end

end