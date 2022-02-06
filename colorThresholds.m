clear;
close all;

cam = webcam;
while true
    original_image = cam.snapshot;
    original_image = imresize(original_image, 0.3);
%     original_image = imread("cube.png");
    
    [L,Centers] = imsegkmeans(original_image,13);
    image = label2rgb(L, im2double(Centers));

    stickerMask = kMeansImageToStickerMask(L);

    subplot(2, 2, 1); imshow(original_image); title("original image");
    subplot(2, 2, 2); imshow(image); title("k-means");
    subplot(2, 2, 3); imshow(stickerMask); title("sticker mask");

    
%     grid = masksToGrid(masks, ["R", "O", "Y", "W", "G", "B", "-"]);
%     grid
end

function [mask] = kMeansImageToStickerMask(L)
    mask = zeros(size(L, 1), size(L, 2));
    for i=1:max(max(L))
        cc = bwlabel(L==i);
        for j=1:max(max(cc))
            count = sum(sum(cc==j));
%             s = squareness(cc==j);
%             s=1;
            if count > 1000 && count < 3000
                s = squareness(cc==j);
                if s > .5 && s < 1.3
                    mask(cc==j) = 1;
%                     imshow(label2rgb(cc==j));
                    1;
                end
%                 disp(count)
            end
        end
%         disp("________________");
%         imshow(label2rgb(cc));
    end
end

function [indices] = CentersToStickerIndices (centers)
    R = double(centers(:,1));
    G = double(centers(:,2));
    B = double(centers(:,3));
    L = R + G + B;
    S = R - B;
    T = R - 2*G + B;
end

function [grid] = masksToGrid(masks, colors) 
    centroids = ones(9, 3)*7;
    counter = 1;
    for i=1:6
        cc = bwlabel(masks(:,:,i));
        for j=1:max(max(cc))
            [x, y] = find(cc == j);
            centroids(counter, 1) = mean(x);
            centroids(counter, 2) = mean(y);
            centroids(counter, 3) = i;
            counter = counter + 1;
        end
    end
    centroids = sortrows(centroids, 1:2, ["ascend", "ascend"]);
    grid = reshape(centroids(1:9,3), 3, 3);
    grid = colors(grid)';
end