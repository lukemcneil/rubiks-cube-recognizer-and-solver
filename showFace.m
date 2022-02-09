function showFace(grid)
    colors = ["R" "B" "O" "G" "W" "Y" "-"];
    cube = ones(3, 3, 6) * 7;
    for i=1:3
        for j=1:3
            cube(i, j, 1) = find(colors==grid(i, j));
        end
    end
    rubplot(cube);
end