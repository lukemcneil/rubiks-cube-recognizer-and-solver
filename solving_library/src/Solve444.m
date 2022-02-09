function solution = Solve444(R)

solution = [];
rotation = {'x0'};
%#ok<*AGROW>

A{1} = {'r','U','r'''};
A{2} = {'r2','U','r2'};

%STEP 1: Solve centres

%Find face with most equal centre-colors:

%rotation tables
rot={'y0','z0'; 'y1','z0';...
     'y0','z1'; 'y1','z1';...
     'y0','z2'; 'y1','z2';...
     'y0','z3'; 'y1','z3';...

     'y2','z0'; 'y3','z0';...
     'y2','z1'; 'y3','z1';...
     'y2','z2'; 'y3','z2';...
     'y2','z3'; 'y3','z3';...

     'x1','z0'; 'x3','z0';...
     'x1','z1'; 'x3','z1';...
     'x1','z2'; 'x3','z2';...
     'x1','z3'; 'x3','z3'};

x = reshape(R([2 3],[2 3],:),4,6);
h = hist(x,1:6);
[col,face] = find(h==4);
n = zeros(24,1);
n(1) = nnz(col==face);
if ~isempty(col)
    for i = 2:24
        Rtest = rubrot2(R,rot(i,:));
        x = reshape(Rtest([2 3],[2 3],:),4,6);
        h = hist(x,1:6);
        [col,face] = find(h==4);
        n(i) = nnz(col==face);
        if n(i) == 6
            break;
        end
    end
    i = find(n==max(n),1);
    R = rubrot2(R,rot(i,:));
        rotation = [rotation rot(i,:)];
end

or = [5,2,6,4,3,1];
rot = {'x1','x1','x1','y1','y2','x0'};
for side = 1:6
    topcol = or(side);
    x = reshape(R([2,3],[2,3],5),1,4);
    y = find(x~=topcol,1);
    move = {'','U','U''','U2'};
    if y~=1
        R = rubrot(R,move{y});
            solution = [solution algrot(move{y},rotation)];
    end
    x = reshape(R([2,3],[2,3],5),1,4);
    y = reshape(R([2,3],[2,3],1),1,4);
    solved = all(x==topcol);
    i = 1;
    while ~solved && i<=4    
        for j=1:sum(y==topcol)
            done = false;
            while ~done
                if y(4)==topcol
                    R = rubrot(R,A{1});
                        solution = [solution algrot(A{1},rotation)];
                    x = reshape(R([2,3],[2,3],5),1,4);
                    y = find(x~=topcol,1);
                    if y~=1
                        R = rubrot(R,move{y});
                            solution = [solution algrot(move{y},rotation)];
                    end                    
                    done = true;
                else
                    R = rubrot(R,'F');
                        solution = [solution algrot({'F'},rotation)];
                end
                y = reshape(R([2,3],[2,3],1),1,4);
            end
        end
        R = rubrot2(R,'z3');
            rotation = [rotation {'z3'}];
        R = rubrot(R,'U''');
            solution = [solution algrot({'U'''},rotation)];
        x = reshape(R([2,3],[2,3],5),1,4);
        y = reshape(R([2,3],[2,3],1),1,4);
        i = i+1;
    end
    solved = all(x==topcol);
    if ~solved
        y = reshape(R([2,3],[2,3],6),1,4);
        for j=1:sum(y==topcol)
            done = false;
            while ~done
                if y(4)==topcol
                    R = rubrot(R,A{2});
                        solution = [solution algrot(A{2},rotation)];
                    x = reshape(R([2,3],[2,3],5),1,4);
                    y = find(x~=topcol,1);
                    if y~=1
                        R = rubrot(R,move{y});
                            solution = [solution algrot(move{y},rotation)];
                    end                    
                    done = true;
                else
                    R = rubrot(R,'D');
                        solution = [solution algrot({'D'},rotation)];
                end
                y = reshape(R([2,3],[2,3],6),1,4);
            end
        end
    end
    R = rubrot2(R,rot{side});  
        rotation = [rotation rot(side)];
end
    
% PAIR-UP EDGES
% moves to set-up edges
B1 = {{'R2','B''','D2'},{'R''','D'''},{'R','D'''},{'B''','D2'},{'B','D2'},{'L''','D'},...
      {'L','D'},{'L2','B','D2'},{'R2','D'''},{'R','B''','D2'},{'R''','B''','D2'},{'D'''},...
      {'D'},{'L','B','D2'},{'L''','B','D2'},{'L2','D'},{'B','L''','D'},{'B2','D2'},...
      {'D2'},{'B','R','D'''},{'D','R''','B''','D2'}};
B2 = {{'R','U''','B''','U','R2'},{'I'},{'R2'},{'B','U','R''','U'''},...
      {'B''','U','R''','U'''},{'B2','R2'},{'L2','B2','R2'},{'L2','B''','U','R''','U'''},...
      {'R'''},{'U''','B''','U','R2'},{'D','B','D''','R2'},{'R'},...
      {'L','B2','R2'},{'L','B''','U','R''','U'''},{'U','B''','U''','R2'},{'U2','R''','U2'},...
      {'B''','R2'},{'U','R''','U'''},{'D''','R','D'},{'B','R2'}};
  
A{3} = {'r','U''','R','U','r''','U''','R''','U'};
A{4} = {'U2','r','U2','r','U2','r','U2','r','U2','r','U2'};

X = [2,4,1,2,1,2;...
     3,4,1,3,1,2;...
     2,4,2,2,1,3;...
     3,4,2,3,1,3;...
     2,4,3,2,1,4;...
     3,4,3,3,1,4;...
     2,4,4,2,1,1;...
     3,4,4,3,1,1;...
     
     1,2,2,3,4,5;...
     1,3,2,2,4,5;...
     4,2,2,2,4,6;...
     4,3,2,3,4,6;...
     4,3,4,2,1,6;...
     4,2,4,3,1,6;...
     1,3,4,3,1,5;...
     1,2,4,2,1,5;...
     
     1,3,3,1,2,5;...
     1,2,3,1,3,5;...
     4,3,3,4,2,6;...
     4,2,3,4,3,6;...
     4,2,1,1,2,6;...
     4,3,1,1,3,6;...
     1,3,1,4,3,5;...
     1,2,1,4,2,5];

Y = [0 3 6 7 9 12 13 16 17 20];
 
rot = {{'x1'},{'z3','x1'},{'z2','x1'},{'x3'},{'z3'},...
       {'x1','z3'},{'x2','z3'},{'z1'},{'y1'},{'y2'},{'y3'}}; 
colors = @(R,x)(sort([R(X(x,1),X(x,2),X(x,3)),R(X(x,4),X(x,5),X(x,6))]));
C   = zeros(24,2);

for i=1:24
    C(i,:) = colors(R,i);
end
D = zeros(1,12);
for i=1:12
    D(i) = ~all(C(2*i-1,:)==C(2*i,:));
end
solved = ~any(D);

while ~solved
    %check if there is an unmatched edge at FU, if not, rotate so there is
    if ~D(12)
        x = find(D,1);
        R = rubrot2(R,rot{x});
            rotation = [rotation rot{x}];
        for i=1:24
            C(i,:) = colors(R,i);
        end
    end
    %find the FUl-twin and place it at FDr
    x = find(ismember(C,C(24,:),'rows'),1);
    if x<=21
        R = rubrot(R,B1{x});
            solution = [solution algrot(B1{x},rotation)];
        for i=1:24
            C(i,:) = colors(R,i);
        end
    end    
    %check if there are at least 3 unmatched edges, if not, apply A{4}
    if nnz(D)<3
        R = rubrot(R,A{4});
            solution = [solution algrot(A{4},rotation)];
        for i=1:24
            C(i,:) = colors(R,i);
        end
        for i=1:12
            D(i) = ~all(C(2*i-1,:)==C(2*i,:));
        end
        continue
    end
    %find the FUr-twin and place it at FRd
    x = find(ismember(C,C(23,:),'rows'),1);
    if x<=20 && x~=2
        R = rubrot(R,B2{x});
            solution = [solution algrot(B2{x},rotation)];
        for i=1:24
            C(i,:) = colors(R,i);
        end
    elseif x==21
        %place any unmatched pair there
        for i=1:12
            D(i) = ~all(C(2*i-1,:)==C(2*i,:));
        end
        y = find(D,1);
        if y~=1
            R = rubrot(R,B2{Y(y)});
                solution = [solution algrot(B2{Y(y)},rotation)]; 
        end
    end
    %apply the algorithm to match them
    R = rubrot(R,A{3});
        solution = [solution algrot(A{3},rotation)]; 
    for i=1:24
            C(i,:) = colors(R,i);
    end
    for i=1:12
        D(i) = ~all(C(2*i-1,:)==C(2*i,:));
    end
    solved = ~any(D);
end

% FIX PARITY
A{5} = {'d2','r2','D2','d2','r2','D2','r2'};
A{6} = {'r2','R2','B2','L''','D2','l''','D2',...
        'r','D2','r''','D2','F2','r''','F2',...
        'l','L','B2','R2','r2'};
%convert to 3x3x3 cube
S = zeros(3,3,6);
for i=1:6
    S(:,:,i) = [R(1:2,1:2,i) R(1:2,4,i);...
                R(4,1:2,i)   R(4,4,i)];
end
E = GetEdges(S);
%check orientation-validity
if mod(sum(E(2,:)),2)==1
    %flip an edge
    R = rubrot(R,A{6});
         solution = [solution algrot(A{6},rotation)]; 
end
for i=1:6
    S(:,:,i) = [R(1:2,1:2,i) R(1:2,4,i);...
                R(4,1:2,i)   R(4,4,i)];
end
E = GetEdges(S);
C = GetCorners(S);
Epar = parity(E(1,:));
Cpar = parity(C(1,:));
if mod(Epar+Cpar,2)==1
    %swap two edges
    R = rubrot(R,A{5});
         solution = [solution algrot(A{5},rotation)]; 
end
for i=1:6
    S(:,:,i) = [R(1:2,1:2,i) R(1:2,4,i);...
                R(4,1:2,i)   R(4,4,i)];
end
% APPLY T45
solution = [solution algrot(Solve45(S),rotation)];
solution = rubopt(solution,4);


