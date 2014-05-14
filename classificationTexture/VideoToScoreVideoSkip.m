function [ out ] = VideoToScoreVideoSkip( video, train, s, thresh, skip)
% video should be a height X width X 3 X frames --- array


height = length(video(:,1,1,1));
width = length(video(1,:,1,1));
frames = length(video(1,1,1,:));
H = height/s;
W = width/s;
out = false(H,W,frames);

for i = 1:ceil(frames/skip)
    %display(strcat('frame number: ',num2str((i-1)*skip+1)));
    out(:,:,(i-1)*skip+1) = ImageToScoreArray(video(:,:,:,(i-1)*skip+1), train, s, thresh);
    for j = (i-1)*skip+2:min(i*skip, frames)
        out(:,:,j) = out(:,:,(i-1)*skip+1);
    end

end