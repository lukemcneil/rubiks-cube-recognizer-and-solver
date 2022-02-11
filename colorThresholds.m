clear;
close all;
addpath(genpath("solving_library"));

cam = webcam;
global cubeToDraw;
fullGrid(1:3,1:3,1:6) = "-";
cubeToDraw = fullGrid;

global currentSide;
currentSide = 1;

global keepLooping;
keepLooping = true;

global paused;
paused = false;

set(gcf, 'KeyPressFcn', @keyPressed)

while keepLooping
    drawnow

    if ~paused
    
    %     original_image = imread("our_images/cube3.png");
        original_image = cam.snapshot;
        original_image = imresize(original_image, 0.1);
        
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
        if grid(1) ~= "-"
            fullGrid(:,:,currentSide) = grid;
            cubeToDraw = fullGrid;
            subplot(2, 3, 6); showFace(fullGrid); title("current side: "+currentSide);
        else
            subplot(2, 3, 6); title("current side: "+currentSide);
        end
%         if size(find(stickerMask==1), 1) ~= 0
            
%         end
    end
end

function [mask] = kMeansImageToStickerMask(L)
    mask = zeros(size(L, 1), size(L, 2));
    for i=1:max(max(L))
        cc = bwlabel(L==i);
        for j=1:max(max(cc))
            count = sum(sum(cc==j));
            if count > 100 && count < 1500
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

function keyPressed(hObject, event)
    global currentSide;
    global keepLooping;
    global paused;
    global cubeToDraw;
    switch event.Key
        case 'rightarrow'
            currentSide = min(currentSide+1, 6);
            disp("new current side: " + currentSide);
        case 'leftarrow'
            currentSide = max(currentSide-1, 1);
            disp("new current side: " + currentSide);
        case 'return'
            disp(Solve45(cubeToDraw));
%             keepLooping = false;
        case 'space'
            paused = ~paused;
    end
end