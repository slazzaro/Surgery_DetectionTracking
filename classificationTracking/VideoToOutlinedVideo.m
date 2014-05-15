function [ video ] = VideoToOutlinedVideo( video, train, n, s, w, thresh )
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here

componentVideo = VideoToScoreVideo( video, train, n, s, w, thresh);
componentVideo = ScoreVideoToComponentVideo( componentVideo );
video = OutlineVideoComponent(video,componentVideo);


end

