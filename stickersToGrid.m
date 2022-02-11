function [grid] = stickersToGrid(stickerMask, image)
    colors = ["R" "G" "B" "O" "W" "Y"];
    stickerColors = zeros(6, 3);
    stickerColors(1,:) = [123, 38, 16];
    stickerColors(2,:) = [12, 120, 84];
    stickerColors(3,:) = [25, 50, 190];
    stickerColors(4,:) = [213, 106, 40];
    stickerColors(5,:) = [160, 180, 220];
    stickerColors(6,:) = [165, 150, 10];

    centroids = ones(9, 3)*-1;
    
    numStickers = max(max(stickerMask));
    if numStickers == 9
        for i=1:numStickers
            [xs, ys] = find(stickerMask == i);
            color = double(squeeze(image(xs(1), ys(1), :)));
            distances = zeros(1, 6);
            for j=1:6
                r2 = (color(1) - stickerColors(j, 1))^2;
                g2 = (color(2) - stickerColors(j, 2))^2;
                b2 = (color(3) - stickerColors(j, 3))^2;
                distances(j) = r2+g2+b2;
            end
%             fprintf("Sticker # %d\n",i);
%             disp(distances);
            [~, idx] = min(distances);
            centroids(i, 1) = mean(xs)*3 + mean(ys);
            centroids(i, 2) = mean(ys);
            centroids(i, 3) = idx;
        end
    else
        disp("there are not 9 stickers");
        grid = ["-" "-" "-"; "-" "-" "-"; "-" "-" "-"];
        return;
    end
    
    centroids = sortrows(centroids, 1);
    grid = reshape(centroids(1:9,3), 3, 3);
    grid = colors(grid)';
end