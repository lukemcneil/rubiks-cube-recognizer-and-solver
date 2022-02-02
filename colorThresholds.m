clear;
close all;

% image = imread("images/WhatsApp Image 2021-02-16 at 7.56.46 PM.jpeg");
image_paths = dir("images");
image_paths = image_paths(3:end);
image = imread("images/" + image_paths(5).name);
image = rgb2hsv(image); 
h = image(:,:,1);
s = image(:,:,2);
v = image(:,:,3);

red_mask = h > 0.95 & h < 1 & s > 0.5 & v > 0.5;
orange_mask = h > 0.06 & h < 0.12 & v > 0.7;
yellow_mask = h > 0.12 & h < 0.18 & s > 0.8 & v > 0.7;
white_mask =  h < 0.02 | h > 0.98 & s < 0.2 & v > 0.8;
green_mask = h > 0.4 & h < 0.46;
blue_mask = h > 0.54 & h < 0.6;
black_mask = v < 0.4;

subplot(3, 4, 1); imshow(hsv2rgb(image)); title("original image");
subplot(3, 4, 2); imshow(image); title("hsv image");
subplot(3, 4, 3); imshow(red_mask); title("red mask");
subplot(3, 4, 4); imshow(orange_mask); title("orange mask");
subplot(3, 4, 5); imshow(yellow_mask); title("yellow mask");
subplot(3, 4, 6); imshow(white_mask); title("white mask");
subplot(3, 4, 7); imshow(green_mask); title("green mask");
subplot(3, 4, 8); imshow(blue_mask); title("blue mask");
subplot(3, 4, 9); imshow(black_mask); title("black mask");

% imtool(image);