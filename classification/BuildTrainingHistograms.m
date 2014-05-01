function [ trainingHistograms ] = BuildTrainingHistograms( trainDir, w )

	widthOfBins = w;
    
    dirContents = dir(trainDir); % all dir contents
    subFolders=[dirContents(:).isdir]; % just subfolder
    folderNames = {dirContents(subFolders).name};    %subfolder names
    folderNames(ismember(folderNames,{'.','..'})) = []; %remove
    imgFiles = dir(strcat(trainDir, '/', folderNames{1}, '/', '*.jpg')); 
    
    trainingHistograms = zeros( 256/widthOfBins, 3, length(imgFiles) );
    
    for i = 1:length(imgFiles);
        currImage = imread(strcat(trainDir, '/',folderNames{1}, '/', imgFiles(i).name));
    	currHist = SimpleHist1D(double(currImage), widthOfBins);
    	trainingHistograms(:,:,i) = currHist(:,:);
    end

end