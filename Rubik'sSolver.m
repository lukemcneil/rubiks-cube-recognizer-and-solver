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
        
        [L,Centers] = imsegkmeans(original_image,13);
        image = label2rgb(L, im2double(Centers));
    
        stickerMask = kMeansImageToStickerMask(L);
    
        onlyStickersImage = cropImage(image, ~stickerMask);
        
%         subplot(2, 3, 1); imshow(original_image); title("original image");
        subplot(1, 3, 1); imshow(image); title("k-means");
%         subplot(2, 3, 4); imshow(stickerMask); title("sticker mask");
        subplot(1, 3, 2); imshow(onlyStickersImage); title("only stickers");
        
        grid = stickersToGrid(bwlabel(stickerMask), image);
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
            if count > 100 && count < 500
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

function keyPressed(~, event)
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
            disp(Solve45(color2idx(cubeToDraw)));
%             keepLooping = false;
        case 'space'
            paused = ~paused;
            if paused
                disp('resumed');
            else 
                disp('paused');
            end
        case {'q', 'escape'}
            keepLooping = false;
    end
end