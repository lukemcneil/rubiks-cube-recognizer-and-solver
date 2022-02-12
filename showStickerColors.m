function showStickerColors()
    global stickerColors;
    temp = ones(66, 99, 3);
    temp(1:33,1:33,1) = stickerColors(1,1);
    temp(1:33,1:33,2) = stickerColors(1,2);
    temp(1:33,1:33,3) = stickerColors(1,3);

    temp(34:66,1:33,1) = stickerColors(2,1);
    temp(34:66,1:33,2) = stickerColors(2,2);
    temp(34:66,1:33,3) = stickerColors(2,3);

    temp(1:33,34:66,1) = stickerColors(3,1);
    temp(1:33,34:66,2) = stickerColors(3,2);
    temp(1:33,34:66,3) = stickerColors(3,3);

    temp(34:66,34:66,1) = stickerColors(4,1);
    temp(34:66,34:66,2) = stickerColors(4,2);
    temp(34:66,34:66,3) = stickerColors(4,3);

    temp(1:33,67:99,1) = stickerColors(5,1);
    temp(1:33,67:99,2) = stickerColors(5,2);
    temp(1:33,67:99,3) = stickerColors(5,3);

    temp(34:66,67:99,1) = stickerColors(6,1);
    temp(34:66,67:99,2) = stickerColors(6,2);
    temp(34:66,67:99,3) = stickerColors(6,3);
    temp = temp / 255;
    imshow(temp);
end