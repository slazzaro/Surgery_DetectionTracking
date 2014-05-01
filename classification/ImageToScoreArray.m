function [ I ] = ImageToScoreArray( image, train, n, s, w, thresh )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

 hists = Histograms1DOpt2(image, n,s,w);
 scores = ScoreArray1D(hists,train);
 scores = log(scores);
 I = mat2gray(scores, [thresh,max(max(scores))]);


end

