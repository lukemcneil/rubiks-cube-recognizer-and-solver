function C = GetCorners2(R)
%
% This function is used to aquire the Corner Orientation/Permutation of a
% 2x2x2 cube.
%
Co = zeros(1,8);

% positions in R of corner facelets 1,2 and 3 (clockwise)
c1 = [1 1 4;2 2 4;2 2 2;1 1 2;...
      1 2 4;2 1 4;2 1 2;1 2 2];
c2 = [1 2 3;2 1 1;2 1 3;1 2 1;...
      2 1 5;2 1 6;1 2 6;1 2 5];
c3 = [1 1 5;1 1 6;2 2 6;2 2 5;...
      1 1 1;2 2 3;2 2 1;1 1 3];
  
%Solved Cube corners
y = [3 4 5;...
     1 4 6;...
     2 3 6;...
     1 2 5;...
     1 4 5;...
     3 4 6;...
     1 2 6;...
     2 3 5];

% Find orientation
x = zeros(8,3);
for i=1:8
    x(i,1) = R(c1(i,1),c1(i,2),c1(i,3));
    x(i,2) = R(c2(i,1),c2(i,2),c2(i,3));
    x(i,3) = R(c3(i,1),c3(i,2),c3(i,3));
    if x(i,2)==2 || x(i,2)==4
        Co(i) = 1;
    elseif x(i,3)==2 || x(i,3)==4
        Co(i) = 2;
    end
end

% Find permutation
x = sort(x,2);
Cp = zeros(1,8);
for i=1:8
    Cp(i)= find(y(:,1)==x(i,1) & y(:,2)==x(i,2) & y(:,3)==x(i,3));
end

C = [Cp;Co];