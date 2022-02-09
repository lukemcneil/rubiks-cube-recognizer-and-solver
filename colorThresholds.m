clear;
close all;

cam = webcam;
while true
%     original_image = imread("our_images/cube3.png");
    original_image = cam.snapshot;
    original_image = imresize(original_image, 0.3);
    
    [L,Centers] = imsegkmeans(original_image,13);
    image = label2rgb(L, im2double(Centers));

    LSTImage = rgb2lst(image);

    stickerMask = kMeansImageToStickerMask(L);

    onlyStickersImage = cropImage(image, ~stickerMask);

    subplot(2, 3, 1); imshow(original_image); title("original image");
    subplot(2, 3, 2); imshow(image); title("k-means");
    subplot(2, 3, 3); imshow(LSTImage); title("LST");
    subplot(2, 3, 4); imshow(stickerMask); title("sticker mask");
    subplot(2, 3, 5); imshow(onlyStickersImage); title("only stickers");

    grid = stickersToGrid(bwlabel(stickerMask), LSTImage);
    grid
end

function [mask] = kMeansImageToStickerMask(L)
    mask = zeros(size(L, 1), size(L, 2));
    for i=1:max(max(L))
        cc = bwlabel(L==i);
        for j=1:max(max(cc))
            count = sum(sum(cc==j));
            if count > 500 && count < 3000
                s = squareness(cc==j);
                if s > .85 && s < 1.3
                    mask(cc==j) = 1;
                    1;
                end
            end
        end
    end
end

function [lstImage] = rgb2lst(image)
    R = double(image(:,:,1))/255;
    G = double(image(:,:,2))/255;
    B = double(image(:,:,3))/255;
    L = (R + G + B) / 3;
    S = ((R - B) + 1) / 2;
    T = ((R - 2*G + B) + 2) / 4;
    lstImage = cat(3, L, S, T);
end

function [croppedImage] = cropImage(image, mask)
    r = image(:,:,1);
    g = image(:,:,2);
    b = image(:,:,3);
    r(mask==1) = 0;
    g(mask==1) = 0;
    b(mask==1) = 0;
    image(:,:,1) = r;
    image(:,:,2) = g;
    image(:,:,3) = b;
    croppedImage = image;
end