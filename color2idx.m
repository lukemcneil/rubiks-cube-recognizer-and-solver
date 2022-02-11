function cube = color2idx(fullgrid)
    colors = ['R' 'B' 'O' 'G' 'W' 'Y' '-'];
    cube = ones(3, 3, 6) * 7;
    for i = 1:6
        cube(fullgrid == colors(i)) = i;
    end
end