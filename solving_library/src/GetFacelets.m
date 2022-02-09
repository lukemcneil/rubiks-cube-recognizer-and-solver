function R = GetFacelets(C,E)
%
% Converts the orientation/permutation to a representation on facelet-level
% (which can now be plotted by rubplot()
%
R = zeros(3,3,6);
for i=1:6
    R(2,2,i) = i;
end

% positions in R of corner facelets 1,2 and 3 (clockwise)
c1 = [1 1 4;1 1 6;3 3 6;3 3 5;...
      3 1 5;3 1 6;1 3 6;1 3 5];
c2 = [1 3 3;3 3 4;3 3 2;1 1 2;...
      1 1 1;3 3 3;3 3 1;1 1 3];
c3 = [1 1 5;3 1 1;3 1 3;1 3 1;...
      1 3 4;3 1 4;3 1 2;1 3 2]; 
  
% positions in R of edge facelets 1 and 2
e1 = [1 2 4;3 2 4;1 2 2;3 2 2;...
      2 1 4;2 3 4;2 1 2;2 3 2;...
      1 2 1;3 2 1;3 2 3;1 2 3];
e2 = [2 1 5;2 1 6;2 3 5;2 3 6;...
      2 3 3;2 1 1;2 3 1;2 1 3;...
      3 2 5;1 2 6;3 2 6;1 2 5];
  
% apply corner permutation  
for i=1:8
    R(c1(i,1),c1(i,2),c1(i,3)) = c1(C(1,i),3);
    R(c2(i,1),c2(i,2),c2(i,3)) = c2(C(1,i),3);
    R(c3(i,1),c3(i,2),c3(i,3)) = c3(C(1,i),3);
end

% apply edge permutation  
for i=1:12
    R(e1(i,1),e1(i,2),e1(i,3)) = e1(E(1,i),3);
    R(e2(i,1),e2(i,2),e2(i,3)) = e2(E(1,i),3);
end

% match corner orientation
for i=1:8
    Ctest = GetCorners(R,'O');
    while Ctest(i)~=C(2,i)
        Rtemp = R;
        R(c1(i,1),c1(i,2),c1(i,3)) = Rtemp(c2(i,1),c2(i,2),c2(i,3));
        R(c2(i,1),c2(i,2),c2(i,3)) = Rtemp(c3(i,1),c3(i,2),c3(i,3));
        R(c3(i,1),c3(i,2),c3(i,3)) = Rtemp(c1(i,1),c1(i,2),c1(i,3));
        Ctest = GetCorners(R,'O');
    end
end 

% match edge orientation
for i=1:12
    Etest = GetEdges(R,'O');
    if Etest(i)~=E(2,i)
        Rtemp = R;
        R(e1(i,1),e1(i,2),e1(i,3)) = Rtemp(e2(i,1),e2(i,2),e2(i,3));
        R(e2(i,1),e2(i,2),e2(i,3)) = Rtemp(e1(i,1),e1(i,2),e1(i,3));
    end
end
