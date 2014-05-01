function [ scores] = ImageToScoreArray( image, train, s, w, thresh )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

 hists = Histograms1D(image,s,w);
 scores = ScoreArray1D(hists,train,thresh);
 scores = Conway(scores);
 scores = Conway(scores);
 
end

