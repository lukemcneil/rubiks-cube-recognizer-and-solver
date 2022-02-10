function result = showFace(grid)
    colors = ["R" "B" "O" "G" "W" "Y" "-"];
    cube = ones(3, 3, 6) * 7;
    for h=1:6
        for i=1:3
            for j=1:3
                cube(i, j, h) = find(colors==grid(i, j, h));
            end
        end
    end
    rubplot(cube);
    result = cube;
end