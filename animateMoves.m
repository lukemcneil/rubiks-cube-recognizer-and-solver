function animateMoves(cube, moves)
    figure;
    if size(moves, 2) > 0
        rubplot(cube); title("next: "+moves(1));
        for i=1:size(moves, 2)
            pause;
            rubplot(cube, rub2move(string(moves(i)))); 
            if i ~= size(moves, 2)
                title("last: "+string(moves(i)+", next: "+string(moves(i+1))))
            else
                title("last: "+string(moves(i)))
            end
            cube = rubrot(cube, rub2move(string(moves(i))));
        end
    end
end