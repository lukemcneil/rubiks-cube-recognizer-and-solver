clear;
close all;

% original_image = imread("images/WhatsApp Image 2021-02-16 at 7.56.46 PM.jpeg");
% image_paths = dir("images");
% image_paths = image_paths(3:end);
% original_image = imread("images/" + image_paths(5).name);
% cam = webcam;
% original_image = cam.snapshot();
% original_image = imresize(original_image, 0.5);
% original_image = imgaussfilt(original_image, 3);
cam = webcam;
% while true
%     original_image = cam.snapshot;
%     original_image = imresize(original_image, 0.3);
    original_image = imread("cube.png");
    
    imshow(original_image);
    
    % edges = edge(rgb2gray(original_image), "canny");
    
    [L,Centers] = imsegkmeans(original_image,13);
    image = label2rgb(L, im2double(Centers));
    imtool(image);

    indices = kMeansImageToStickerMask(L);
    
    image = rgb2hsv(image); 
    % imtool(image);
    h = image(:,:,1);
    s = image(:,:,2);
    v = image(:,:,3);
    
%     red_mask = h > 0.92 & h < 1 & s > 0.5 & v > 0.2;
%     orange_mask = h > 0.04 & h < 0.12 & s > 0.7;
%     yellow_mask = h > 0.12 & h < 0.18;
%     white_mask = v > 0.7 & s < 0.4;
%     green_mask = h > 0.35 & h < 0.48;
%     blue_mask = h > 0.55 & h < 0.65 & s > 0.5;
%     black_mask = v < 0.4;
%     
%     se = strel("square", 25);
%     red_mask = imopen(red_mask, se);
%     orange_mask = imopen(orange_mask, se);
%     yellow_mask = imopen(yellow_mask, se);
%     white_mask = imopen(white_mask, se);
%     green_mask = imopen(green_mask, se);
%     blue_mask = imopen(blue_mask, se);
%     
%     subplot(3, 4, 1); imshow(original_image); title("original image");
%     subplot(3, 4, 2); imshow(hsv2rgb(image)); title("k-means");
%     subplot(3, 4, 3); imshow(image); title("hsv image");
%     subplot(3, 4, 4); imshow(red_mask); title("red mask");
%     subplot(3, 4, 5); imshow(orange_mask); title("orange mask");
%     subplot(3, 4, 6); imshow(yellow_mask); title("yellow mask");
%     subplot(3, 4, 7); imshow(white_mask); title("white mask");
%     subplot(3, 4, 8); imshow(green_mask); title("green mask");
%     subplot(3, 4, 9); imshow(blue_mask); title("blue mask");
%     subplot(3, 4, 10); imshow(black_mask); title("black mask");
% %     subplot(3, 4, 11); imshow(edges); title("edges");
%     
%     masks(:,:,1) = red_mask;
%     masks(:,:,2) = orange_mask;
%     masks(:,:,3) = yellow_mask;
%     masks(:,:,4) = white_mask;
%     masks(:,:,5) = green_mask;
%     masks(:,:,6) = blue_mask;
%     
%     grid = masksToGrid(masks, ["R", "O", "Y", "W", "G", "B", "-"]);
%     grid
% end

function [mask] = kMeansImageToStickerMask(L)
    for i=1:max(max(L))
        cc = bwlabel(L==i);
        for j=1:max(max(cc))
            
            count = sum(sum(cc==j));
            if count > 4000 && count < 5500 
                imshow(label2rgb(cc));
                disp(count)
            end
            
        end
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