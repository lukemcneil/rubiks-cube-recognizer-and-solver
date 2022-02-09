function varargout = rubsolve(R0,varargin)
%
% Syntax: [R,solution,time] = rubsolve(R)
% Solves an arbitrary state of Rubik's cube using a simple beginners
% step-method:
% 1. FORM CROSS ON TOP
% 2. MATCH EDGES OF CROSS
% 3. MOVE CORNERPIECES TO CORRECT POSITIONS/ORIENTATIONS
% 4. COMPLETE MIDDLE LAYER
% 5. FORM CROSS ON FINAL LAYER
% 6. POSITION CORNERPIECES
% 7. FINISH BY PLACING EDGEPIECES CORRECTLY
%
% All steps are pre-programmed using a set of algorithms, except for the
% first step. Here it will randomly generate N sequences of M moves, hoping
% that one of them will yield a cross somewhere. M thus is the upperbound
% on the number of steps that will be used to form the cross. Increasing M
% will result in a less efficient solution, but will be faster to
% calculate.
%

d = size(R0,1);
if d~=3
    error('Input can only be a 3x3x3 cube')
end
if nargin > 1
    if (strcmp(varargin{1},'Animate')||strcmp(varargin{1},'animate')) && ...
        varargin{2} == 1
        animate = true;
    else
        animate = false;
    end
else 
    animate = false;
end
solution = {};
rotations = {};
a = [0 3 2 1];
b = [2 1 0 3];

DefaultCam = [33.12 11.73 10.74];
DefaultView = [109.5,17.5];

if strcmp(get(gcf,'Name'),'Rubik')
    campos = get(gca,'CameraPosition');
    view   = get(gca,'View');
else
    campos = DefaultCam;
    view   = DefaultView;
end


%list of algorithms
A{1} =  {'x32','z31','y32','z33','x32'};
A{2} =  {'y12','y32','z12','y12','y32'};                 
A{3} =  {'x32','z33','y12','z31','x32'};
A{4} =  {'y31','z33','y33','z31'};
A{5} =  {'z33','y31','z31','y33'};
A{6} =  {'z13','y33','z11','y31','z11','x31','z13','x33'};
A{7} =  {'z11','y13','z13','y11','z13','x33','z11','x31'};
A{8} =  {'x33','y33','z13','y31','z11','x31'};
A{9} =  {'x33','z13','y33','z11','y31','x31'};
A{10} = {'y31','z11','y33','z11','y31','z12','y33','z12'};
A{11} = {'y33','z13','y31','z13','y33','z12','y31','z12'};
A{12} = {'y11','z11','y31','z13','y13','z11','y33','z12'};
A{13} = {'y33','z11','y33','z13','y33','z13','y33','z11','y31','z11','y32'};

R = R0;
tic

%STEP 1A: FORM CROSS ON TOP
crossel = 2:2:8;
rot = {'y3','x1','y1','x3','x0','y2'};
n = zeros(1,6);
for i=1:6
    x = R(2,2,i);
    temp = R(:,:,i);
    n(i) = nnz(temp(crossel)==x);
end
if n(5)==max(n)
    pickside = 5;
else
    pickside = find(n==max(n),1);
end
R = rubrot2(R,rot{pickside}); rotations = [rotations rot{pickside}];
temp = R(:,:,5);
col = temp(2,2);
n = nnz(temp(crossel)==col);
while n~=4
    for i=1:5
        if i~=5
            temp = R(:,:,1);
        else
            temp = R(:,:,6);
        end
        x = crossel(find(temp(crossel)==col,1));
        if isempty(x)
            R = rubrot2(R,'z3'); rotations = [rotations 'z3'];
            continue
        end
        if i~=5
            while R(3,2,5)==col
                R = rubrot(R,'z13'); solution = [solution algrot('z13',rotations)];
            end
        end
        while numel(x)~=0
            if x==2||x==6
                if x==6
                    R = rubrot(R,'x33'); solution = [solution algrot('x33',rotations)];
                end
                while R(2,1,5)==col
                    R = rubrot(R,'z13'); solution = [solution algrot('z13',rotations)];
                end
                if i~=4
                    R = rubrot(R,'y13'); solution = [solution algrot('y13',rotations)];
                else
                    R = rubrot(R,'y12'); solution = [solution algrot('y12',rotations)];
                end
            else
                if x==4
                    R = rubrot(R,'x33'); solution = [solution algrot('x33',rotations)];
                end
                while R(2,3,5)==col
                    R = rubrot(R,'z13'); solution = [solution algrot('z13',rotations)];
                end
                if i~=4
                    R = rubrot(R,'y33'); solution = [solution algrot('y33',rotations)];
                else
                    R = rubrot(R,'y32'); solution = [solution algrot('y32',rotations)];
                end
            end
            temp = R(:,:,1);
            x = crossel(find(temp(crossel)==col,1));
        end
        temp = R(:,:,5);
        n = nnz(temp(crossel)==col);
        R = rubrot2(R,'z3'); rotations = [rotations 'z3'];
        if n==4
            break
        end
    end
end
%%STEP 1B: MATCH EDGE COLORS
EdgeCol = zeros(1,4);
FaceCol = rubinfo(R,'FaceColors(1:4)');
for side=1:4
    EdgeCol(side) = R(1,2,side);
end

%check if edge colors can be matched by twisting U
test = [EdgeCol EdgeCol];
for i=1:4
    x = all(FaceCol==test(i:i+3));
    if x
        R = rubrot(R,['z1' num2str(a(i))]);
        solution = [solution algrot(['z1' num2str(a(i))],rotations)]; %#ok<*AGROW>
        R = rubrot2(R,'z3');
        rotations = [rotations 'z3'];
        break
    end
end

if ~x
    x = zeros(1,3);
    for i=1:3
        x(i) = find(EdgeCol==FaceCol(i));
        EdgeCol([i,x(i)]) = EdgeCol([x(i),i]);
        if x(i)-i>=0
            x(i) = x(i)-i;
        else
            x(i) = x(i)-i+4;
        end
    end

    for i=1:3
        if x(i)>0
            R = rubrot(R,A{x(i)});
            solution = [solution algrot(A{x(i)},rotations)];
        end
        if sum(x(i+1:end))~=0
            R = rubrot2(R,'z3');
            rotations = [rotations 'z3'];
        end
    end
end

%%STEP 2: MOVE ALL CORNERPIECES TO CORRECT POSITION
TopCol = rubinfo(R,'FaceColors(5)');
while nnz(R(:,:,5)==TopCol)~=9
    [Bcorners,Tcorners,TCE,TopCol] = rubinfo(R,'BCorners',...
                                               'TCorners',...
                                               'TCornersEnd',...
                                               'FaceColors(5)');
    Bcorners = sort(Bcorners,2);
    Tcorners = sort(Tcorners,2);
    TCE = sort(TCE,2);
    for i=1:4   %locate cornerpieces on bottom row
        x(i) = sum(Bcorners(i,:)==TopCol);
    end
    y = find(x,1);  %pick first cornerpiece
    
    goodorientation = true;
    if isempty(y) %no cornerpieces on bottom row -> find one and bring it down if needed
        for i=1:4
            x(i) = ~all(Tcorners(i,:)==TCE(i,:));
        end
        y = find(x,1);
        if isempty(y)                       % cornerpieces in good place, wrong orientation.
            goodorientation = false;
            temp = [3 0 4 0 0 0 2 0 1];
            y = temp(find(R(:,:,5)~=TopCol,1));
            R = rubrot2(R,['z' num2str(a(y))]);
            rotations = [rotations ['z' num2str(a(y))]];
        else                                % cornerpiece has to be brought down.
            R = rubrot2(R,['z' num2str(a(y))]);
            rotations = [rotations ['z' num2str(a(y))]];
            R = rubrot(R,A{4});         %piece has been brought down now
            solution = [solution algrot(A{4},rotations)];
            Bcorners = rubinfo(R,'BCorners');
            Bcorners = sort(Bcorners,2);
            y = 1;
        end
    end
    
    if goodorientation
        TCE = rubinfo(R,'TCornersEnd');
        TCE = sort(TCE,2);
        for i=1:4   %locate endposition of this piece
            x(i) = all(Bcorners(y,:)==TCE(i,:));
        end
        x = find(x);
        y = x-y;                   %number of rotations needed to place piece underneath endposition
        if y<0
            y = y+4;
        end
        if y~=0
            R = rubrot(R,['z3' num2str(y)]);    
            solution = [solution algrot(['z3' num2str(y)],rotations)];
        end
        R = rubrot2(R,['z' num2str(a(x))]);
        rotations = [rotations ['z' num2str(a(x))]];
    end

    %cornerpiece is now correctly placed underneath goal-position, apply
    %A{4}/A{5} (first determine which is best with testcube)

    Rtest = cell(1,2);
    Rtest{1} = rubrot(R,A{4});
    Rtest{2} = rubrot(R,A{5});
    count = 1;
    while Rtest{1}(3,3,5)~=TopCol && Rtest{2}(3,3,5)~=TopCol
        Rtest{1} = rubrot(Rtest{1},A{4});
        Rtest{2} = rubrot(Rtest{2},A{5});
        count = count+1;
    end
    winner = find([Rtest{1}(3,3,5)==TopCol,Rtest{2}(3,3,5)==TopCol],1);
    for i=1:count
        R = rubrot(R,A{winner+3});
        solution = [solution algrot(A{winner+3},rotations)];
    end
end

%%STEP 3: MIDDLE LAYER
R = rubrot2(R,'x2');
rotations = [rotations 'x2'];
Layer2 = 1;
for i=1:4
    Layer2 = Layer2 * all(R(2,:,i)==R(2,2,i));
end
while ~Layer2
    [EdgeCol FaceCol TopCol] = rubinfo(R,'TEdges','FaceColors(1:4)','FaceColors(5)');
    y = find(sum(EdgeCol~=TopCol,2)==2,1);      %position of edge to select
    if isempty(y)   %no suitable edges left on top row
        for i=1:4
            x(i) = ~all(R(2,:,i)==R(2,2,i));    %faces with unfinished 2nd row
        end
        x = find(x,1);
        R = rubrot2(R,['z' num2str(a(x))]);   %rotate cube to this face
        rotations = [rotations ['z' num2str(a(x))]];
        x = find(R(2,:,1)~=R(2,2,1),1);
        switch x
            case 1      %left edge has to brought up: A{7}
                R = rubrot(R,A{7});
                solution = [solution algrot(A{7},rotations)];
            case 3      %right edge has to be brought up: A{6}
                R = rubrot(R,A{6});
                solution = [solution algrot(A{6},rotations)];
        end
        continue
    end
    edge = EdgeCol(y,:);                        %colors of selected edge
    x = find(FaceCol==edge(1));                 %goal-position of selected edge
    y = x-y;                                    %number of rotations of top-row needed
    if y<0
        y = y+4;
    end
    if y~=0
        R = rubrot(R,['z1' num2str(y)]);
        solution = [solution algrot(['z1' num2str(y)],rotations)];
    end
    R = rubrot2(R,['z' num2str(a(x))]);         %rotate cube accordingly
    rotations = [rotations ['z' num2str(a(x))]];

    FaceCol = rubinfo(R,'FaceColors(1:4)');
    x = find(FaceCol==edge(2));                 %determine whether edge has to move to the left/right
    switch x
        case 2      %to the right, use A{6}
            R = rubrot(R,A{6});
            solution = [solution algrot(A{6},rotations)];            
        case 4      %to the left, use A{7}
            R = rubrot(R,A{7});
            solution = [solution algrot(A{7},rotations)];  
    end
    Layer2 = 1;
    for i=1:4
        Layer2 = Layer2 * all(R(2,:,i)==R(2,2,i));
    end
end

%%STEP 4: BUILD CROSS ON FINAL LAYER
TopCol = rubinfo(R,'FaceColors(5)');
%first check what the situation is: cross/bar/L-shape/other

cross = ~~rubcross(R,5);
if cross
    situation = 'Cross';
else
    bar = all(R(2,:,5)==TopCol) | all(R(:,2,5)==TopCol);
    if bar
        situation = 'Bar';
    else
        edges = [2,4,6,8];
        r = R(:,:,5);
        Lshape = nnz(r(edges)==TopCol)>=1;
        if Lshape
            situation = 'Lshape';
        else
            situation = 'Dot';
        end
    end
end

switch situation
    case 'Cross'
        %Continue to step 5
    case 'Bar'
        %Orient the bar from L to R (horizontal)
        if all(R(:,2,5)==TopCol) %vertical bar
            R = rubrot2(R,'z1');
            rotations = [rotations 'z1'];
        end
        R = rubrot(R,A{8});
        solution = [solution algrot(A{8},rotations)];
    case 'Lshape'
        %Orient the L-shape to L and B
        x = sum(find(r(edges)==TopCol));
        c = [3 4 6 7;0 3 1 2];
        x = c(2,c(1,:)==x);
        if x~=0
            R = rubrot2(R,['z' num2str(x)]);
            rotations = [rotations ['z' num2str(x)]];
        end
        R = rubrot(R,A{9});
        solution = [solution algrot(A{9},rotations)];
    case 'Dot'
        R = rubrot(R,[A{8},'z12',A{9}]);
        solution = [solution algrot([A{8},'z12',A{9}],rotations)];
end

%%STEP 5: Permuting corner pieces
solved = false;
while ~solved
    [Tcorners TCE] = rubinfo(R,'TCorners','TCornersEnd');
    temp = sort([Tcorners;Tcorners],2);
    TCE = sort(TCE,2);
    for i = 1:4
        correct = nnz(all(temp(i:i+3,:)==TCE,2));   %check how many corners are in the correct place
        if correct>=2
            break
        end
    end

    R = rubrot(R,['z1',num2str(a(i))]);
    solution = [solution algrot(['z1' num2str(a(i))],rotations)];

    if correct==2
        temp = ~all(temp(i:i+3,:)==TCE,2);      %cornerpieces that need to be switched
        temp = [temp;temp]; %#ok<AGROW>
        adj  = [1 1 0 0]';
        dia  = [1 0 1 0]';
        solved = false;
        for i=1:4                               
            if all(temp(i:i+3,:)==adj)          %pieces to switch are adjecent
                R = rubrot2(R,['z' num2str(a(i))],'animate',animate');
                rotations = [rotations ['z' num2str(a(i))]];
                R = rubrot(R,A{12});
                solution = [solution algrot(A{12},rotations)];
                solved = true;
                break
            elseif all(temp(i:i+3,:)==dia)      %pieces to switch are diagonal
                R = rubrot(R,A{12});
                solution = [solution algrot(A{12},rotations)];
                break
            end
        end
    else
        solved = true;
    end
end

%%STEP 6: Orienting top corners
%Because there are too many specific situations, a trial and error solution
%will be employed.
combs = [1 1 1;2 2 1;1 2 1;2 1 1;1 1 2;2 2 2;1 2 2;2 1 2]+9;
solved = nnz(R(:,:,5)==R(2,2,5))==9;
if ~solved
    for i = 1:4     %for all cube orientations, try A{10} and A{11}
		rot = ['z1',num2str(i-1)];
		B = A{10};
        Rtest = rubrot(R,[rot,B]);
        solved = nnz(Rtest(:,:,5)==Rtest(2,2,5))==9;
        if ~solved
			B = A{11};
            Rtest = rubrot(R,[rot,B]);
            solved = nnz(Rtest(:,:,5)==Rtest(2,2,5))==9;
            if solved
                break
			else
				C = {'z10','z11','z12','z13'};
                for j = 1:6     %for all algorithm combinations
                    for k = 1:4
                		comb = combs(j,:);
                		B = [A{comb(1)},C{k},A{comb(2)},A{comb(3)}];
                		Rtest = rubrot(R,[rot,B]);
                		solved = nnz(Rtest(:,:,5)==Rtest(2,2,5))==9;
                		if solved
                    		break
                		end
                    end
                    if solved
						break
                    end
                end
            end
            if solved
                break
            end
        else
            break
        end
    end
    R = rubrot(R,[rot,B]);
    solution = [solution algrot([rot,B],rotations)];
end

%%STEP 7: Permuting Edges

%twist U to place corner pieces correctly
[Tcorners TCE FaceCol] = rubinfo(R,'TCorners','TCornersEnd','FaceColors(1:4)');
temp = [Tcorners;Tcorners];
correct = 0;
i = 0;
while correct~=4
    i = i+1;
    correct = nnz(all(temp(i:i+3,:)==TCE,2));
end
R = rubrot(R,['z1',num2str(a(i))]);
solution = [solution algrot(['z1' num2str(a(i))],rotations)];

correct = 0;
while correct~=4
    EdgeCol = zeros(1,4);
    for side=1:4
        EdgeCol(side) = R(1,2,side);
    end
    correct = nnz(FaceCol==EdgeCol);    %number of correct edge-pieces (0,1 or 4);
    switch correct
        case 0
            R = rubrot(R,A{13});
            solution = [solution algrot(A{13},rotations)];
        case 1
            x = find(FaceCol==EdgeCol);
            R = rubrot2(R,['z' num2str(b(x))]); %rotate correct piece to the back
            rotations = [rotations ['z' num2str(b(x))]];
            R = rubrot(R,A{13});
            solution = [solution algrot(A{13},rotations)];
            FaceCol = rubinfo(R,'FaceColors(1:4)');
        case 4
            %cube solved
    end
end


t=1;
while t<=numel(solution)
    if isempty(solution{t})
        solution(t)=[];
    else
        t=t+1;
    end
end
solution = rubopt(solution);

if animate
    rubplot(R0,solution);
else
    R = ruborient(R,'default');
    set(gca,'CameraPosition',campos,'View',view);
end

total_time = toc;

switch nargout
    case 0
        return
    case 1
        varargout{1} = R;
    case 2
        varargout{1} = R;       
        varargout{2} = solution;
    case 3
        varargout{1} = R;
        varargout{2} = solution;
        varargout{3} = total_time;
    case 4
        varargout{1} = R;
        varargout{2} = solution;
        varargout{3} = total_time;
        varargout{4} = numel(solution);
end