function [ ] = displayHeatmap( name1, name2, img1, img2, shouldUseImages)
% Displays heatmap for the difference between two images with the names given
% if shouldUseImages == 1 then img1 and img2 can be used instead of reading
% images with the names given
if (shouldUseImages ~= 1)
    img1 = imread(name1);
    img2 = imread(name2);
end
diff = double(img1) - double(img2);
diff2(:,:) = abs(diff(:,:,1)) + abs(diff(:,:,2)) + abs(diff(:,:,3));
colormap('default');
imagesc(diff2);
colorbar

end

