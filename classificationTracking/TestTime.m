function [ ] = TestTime(trainingHistograms, vidFrame, s, widthOfBins, thresh, skip)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

tic
componentVideo = VideoToScoreVideoSkip( double(vidFrame), trainingHistograms, s, widthOfBins, thresh, skip);
[componentVideo, num] = ScoreVideoToComponentVideo( componentVideo );
toc

end

