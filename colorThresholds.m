clear;
close all;

% original_image = imread("images/WhatsApp Image 2021-02-16 at 7.56.46 PM.jpeg");
% image_paths = dir("images");
% image_paths = image_paths(3:end);
% original_image = imread("images/" + image_paths(5).name);
cam = webcam;
original_image = cam.snapshot();
original_image = imresize(original_image, 0.5);
% original_image = imgaussfilt(original_image, 3);
% original_image = imread("cube.png");

edges = edge(rgb2gray(original_image), "canny");

[L,Centers] = imsegkmeans(original_image,13);
image = label2rgb(L, im2double(Centers));

image = rgb2hsv(image); 
imtool(image);
h = image(:,:,1);
s = image(:,:,2);
v = image(:,:,3);

red_mask = h > 0.92 & h < 1 & s > 0.5 & v > 0.2;
orange_mask = h > 0.04 & h < 0.12 & s > 0.7;
yellow_mask = h > 0.12 & h < 0.18;
white_mask =  h > 0.5 & h < 0.7 & v > 0.8;
green_mask = h > 0.35 & h < 0.48;
blue_mask = h > 0.55 & h < 0.65 & s > 0.5;
black_mask = v < 0.4;

subplot(3, 4, 1); imshow(original_image); title("original image");
subplot(3, 4, 2); imshow(hsv2rgb(image)); title("k-means");
subplot(3, 4, 3); imshow(image); title("hsv image");
subplot(3, 4, 4); imshow(red_mask); title("red mask");
subplot(3, 4, 5); imshow(orange_mask); title("orange mask");
subplot(3, 4, 6); imshow(yellow_mask); title("yellow mask");
subplot(3, 4, 7); imshow(white_mask); title("white mask");
subplot(3, 4, 8); imshow(green_mask); title("green mask");
subplot(3, 4, 9); imshow(blue_mask); title("blue mask");
subplot(3, 4, 10); imshow(black_mask); title("black mask");
subplot(3, 4, 11); imshow(edges); title("edges");


% imtool(image);