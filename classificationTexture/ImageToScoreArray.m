function [ scores] = ImageToScoreArray( image, train, s, thresh )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

 hists = Histograms1D(image,s);
 scores = ScoreArray1D(hists,train,thresh);
 scores = Conway(scores);
 scores = Conway(scores);
 
end

