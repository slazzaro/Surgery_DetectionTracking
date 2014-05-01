function [ bestThresh ] = ThresholdSelection(  trainDir, videoPath, n, s, widthOfBins, thresh, p)
%This function is used for selecting the optimal threshold by comparing the
%fraction of the non-thresholded content which lies in the principal
%component.  The variable "p" should represent the fraction of the first
%frame of the video that contains the desired object... example: p=0.04.

    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing training images...'));
    trainingHistograms = BuildTrainingHistograms(trainDir, widthOfBins);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading image...'));
    video = VideoReader(videoPath);
    image = double(read(video,1));
    bestThresh = 0;
    bestRatio = 0;
    for t = thresh
        disp('-------------------------------------------------------------');
        disp(strcat('Testing Threshold Value: ',num2str(t)))
        scoreImage = ImageToScoreArray( image, trainingHistograms, n, s, widthOfBins, t );
        pixels = prod(size(scoreImage)); %#ok<PSIZE>
        [L,num] = bwlabeln(scoreImage);
        max = 0;
        total = 0;
        for i = 1:num
            temp = sum(sum(L==i));
            total = total+temp;
            if (temp>max)
                max = temp;
            end
        end
        display(strcat('Fraction of pixels above threshold:',num2str(total/pixels)));
        display(strcat('Fraction of these pixels in principal component:',num2str(max/total)));
        if (0.9>total/pixels)
            if (total/pixels>p)
                if (max/total>bestRatio)
                    bestRatio = max/total;
                    bestThresh = t;
                end
            end
        end
    end

end

