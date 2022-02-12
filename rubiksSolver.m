clear;
close all;
addpath(genpath("solving_library"));

cam = webcam;
global cubeToDraw;
fullGrid(1:3,1:3,1:6) = '-';
cubeToDraw = fullGrid;

global currentSide;
currentSide = 1;
lastSide = 0;

global keepLooping;
keepLooping = true;

global paused;
paused = false;

global centerColor;
centerColor = [0 0 0];

global stickerColors;
stickerColors = zeros(6, 3);
stickerColors(1,:) = [123, 38, 16];
stickerColors(2,:) = [12, 120, 84];
stickerColors(3,:) = [25, 50, 190];
stickerColors(4,:) = [213, 106, 40];
stickerColors(5,:) = [160, 180, 220];
stickerColors(6,:) = [165, 150, 10];

viewAngle = [109.5 156.5 254 -15.5 113 68
             17.5 20.5 23.5 25.5 53 -70];

set(gcf, 'KeyPressFcn', @keyPressed)
while keepLooping
    drawnow

    if ~paused
    %     original_image = imread("our_images/cube3.png");
        original_image = cam.snapshot;
        original_image = imresize(original_image, 128/size(original_image,2));
%         original_image = rgb2hsv(original_image);
%         original_image(:,:,2) = 1.1*original_image(:,:,2);
%         %original_image(original_image(:,:,2) > 1) = 1;
%         original_image = uint8(hsv2rgb(original_image)*255);
        
        [L,Centers] = imsegkmeans(original_image,17);
        image = label2rgb(L, im2double(Centers));
    
        stickerMask = kMeansImageToStickerMask(L);
    
        onlyStickersImage = cropImage(image, ~stickerMask);
        
%         subplot(2, 3, 1); imshow(original_image); title("original image");
        subplot(1, 3, 1); imshow(image); title("k-means");
%         subplot(2, 3, 4); imshow(stickerMask); title("sticker mask");
        subplot(1, 3, 2); imshow(onlyStickersImage); title("only stickers");
        
        grid = stickersToGrid(bwlabel(stickerMask), image, currentSide);
        if grid(1) ~= "-"
            fullGrid(:,:,currentSide) = grid;
            cubeToDraw = fullGrid;
            subplot(1, 3, 3); rubplot(color2idx(fullGrid)); title("current side: "+currentSide); 
            view(viewAngle(1, currentSide), viewAngle(2, currentSide));
        elseif lastSide ~= currentSide
            lastSide = currentSide;
            subplot(1, 3, 3); rubplot(color2idx(fullGrid)); title("current side: "+currentSide);
            view(viewAngle(1, currentSide), viewAngle(2, currentSide));
        end
    end
end

% kill program
close all;
clear cam;
fprintf("Rubik's Cube Solver Quit.\n");

function [mask] = kMeansImageToStickerMask(L)
    mask = zeros(size(L, 1), size(L, 2));
    for i=1:max(max(L))
        cc = bwlabel(L==i);
        for j=1:max(max(cc))
            count = sum(sum(cc==j));
            if count > 70 && count < 250
                s = squareness(cc==j);
                if s > 0.8
                    mask(cc==j) = 1;
                    1;
                end
            end
        end
    end
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

function keyPressed(~, event)
    global currentSide;
    global keepLooping;
    global paused;
    global cubeToDraw;
    global centerColor;
    global stickerColors;
    switch event.Key
        case 'rightarrow'
            currentSide = min(currentSide+1, 6);
            disp("new current side: " + currentSide);
        case 'leftarrow'
            currentSide = max(currentSide-1, 1);
            disp("new current side: " + currentSide);
        case 'return'
            disp(Solve45(color2idx(cubeToDraw)));
        case 'space'
            paused = ~paused;
            if paused
                disp('resumed');
            else 
                disp('paused');
            end
        case {'q', 'escape'}
            keepLooping = false;
        case '1'
            stickerColors(1,:) = centerColor;
        case '2'
            stickerColors(2,:) = centerColor;
        case '3'
            stickerColors(3,:) = centerColor;
        case '4'
            stickerColors(4,:) = centerColor;
        case '5'
            stickerColors(5,:) = centerColor;
        case '6'
            stickerColors(6,:) = centerColor;
    end
end