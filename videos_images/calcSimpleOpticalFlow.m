function [ newPositions ] = calcSimpleOpticalFlow( centroids, img1, refImg, neighborSize, cutoffDist, penalty, useOrigColor)
%UNTITLED Summary of this function goes here
%   centroids: n x 3 matrix where n is the number of centroids showing
%   neighborSize: size of neighborhood to look at.  Should be odd
%   useOrigColor: 1 if use centroid original color, 0 if use most recent
%                   color
%
%   returns 0 for x and y of centroid if its out of view bounds or doesn't
%  have a good enough match in the view
%
%   Assumes: brightness constant, small motion changes betw frames

% NOTE: can also create a variation of this function where put a histogram
% of pixels in neighborhood around the current centroid vals and then find
% best matching histogram by moving around neighborhood

if (~penalty)
    penalty = 1;
end

newPositions = zeros(size(centroids,1), size(centroids,2));
imgWidth = size(img1,2);
imgHeight = size(img1,1);
for i = 1:size(centroids,1)
    currCentr = centroids(i,:);
    row = currCentr(1);
    col = currCentr(2);
    if useOrigColor == 1
        pixRef = [currCentr(3) currCentr(4) currCentr(5)]';
    else
        pixRef = double(refImg(row,col,:));
    end
%     pixRef = pixRef(:);
    indent = floor(neighborSize / 2);
    bestDist = 1000000;
    if (cutoffDist > bestDist)
        cutoffDist = bestDist - 1;
    end
    for kRow = -indent:indent
        for kCol = -indent:indent
            testRow = max(1, row + kRow);
            testRow = min(imgHeight, testRow);
            testCol = max(1, col + kCol);
            testCol = min(imgWidth, testCol);
            pixTest = double(img1(testRow, testCol,:));
            pixTest = pixTest(:);
            dist = norm(pixRef - pixTest);
            dist = dist^2;
            %prefer points closer to old centroid so put penalty
            dist2center = sqrt((testRow - centroids(i,1))^2 + ...
                (testCol - centroids(i,2))^2) *exp(penalty);
            dist = dist + dist2center;
            if (dist < cutoffDist)
                if (dist < bestDist)
                    newPositions(i,1) = testRow;
                    newPositions(i,2) = testCol;
                    bestDist = dist;
                end
            end
        end
    end
end

end

