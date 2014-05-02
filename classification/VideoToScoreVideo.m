function [ out ] = VideoToScoreVideo( video, train, s, w, thresh)
% video should be a height X width X 3 X frames --- array


height = length(video(:,1,1,1));
width = length(video(1,:,1,1));
frames = length(video(1,1,1,:));
H = height/s;
W = width/s;
out = false(H,W,frames);

for i = 1:frames
    display(strcat('frame number: ',num2str(i)));
    out(:,:,i) = ImageToScoreArray(video(:,:,:,i), train, s, w, thresh);
end

end