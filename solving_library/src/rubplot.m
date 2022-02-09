function varargout = rubplot(R,varargin)
%
% Plots the cube-state. Can also be used to plot the move itself
% (animation) by passing a move as second parameter.
% Example:
% rubplot(R); will just plot R
% rubplot(R,'x11'); will plot R and the move 'x11' on R.
% Also, a sequence of moves in a string-cell is permitted.
%

Rbackup = R;
d = size(R,1);
DefaultCam = [33.12 11.73 10.74];
DefaultView = [109.5,17.5];

if nargin == 2
    move = varargin{1};
    if iscell(move)
        for i = 1:numel(move)
            R = rubplot(R,move{i});
        end
        varargout{1} = R;
        return
    end  
elseif nargin<1 || nargin>2
    error('Number of input arguments unsuitable: rubplot(R,move)')
end

if strcmp(get(gcf,'Name'),'Rubik')
    campos = get(gca,'CameraPosition');
    view   = get(gca,'View');
else
    campos = DefaultCam;
    view   = DefaultView;
    set(gcf,'Name','Rubik')
end

map =   [255   0   0;...          %red
           0   0 255;...          %blue    
         255 165   0;...          %orange  
           0 255   0;...          %green
         255 255 255;...          %white
         255 255   0;...          %yellow
         190 190 190]/255;        %gray

S = rubcoord(d);
hold off
for i=1:6
    for j = 1:d^2
        s = S(:,:,i);
        r = R(:,:,i);
        fill3(s{j}(:,1),s{j}(:,2),s{j}(:,3),map(r(j),:))
        hold on
    end
end
axis([-1 1 -1 1 -1 1]*d/sqrt(2))
set(gca,'CameraPosition',campos,'View',view);
axis off
axis square
hold off

if nargin == 2 && str2double(move(3))~=0
    dir = move(1);
    row = str2double(move(2:end-1)); 
    num = str2double(move(end));
    C = rubrotcoord(d);
    C = C{row,double(dir)-119};

    switch dir
        case 'x'
            RM = @(x)([1 0 0;0 cos(x) -sin(x);0 sin(x) cos(x)]);
        case 'y'
            RM = @(x)([cos(x) 0 sin(x);0 1 0;-sin(x) 0 cos(x)]);         
        case 'z'
            RM = @(x)([cos(x) -sin(x) 0;sin(x) cos(x) 0;0 0 1]);          
    end
    
    step  = 5*[1 2 1];
    angle = [pi/2 pi -pi/2];
    
    step  = step(num);
    angle = angle(num)/step;   
    
    for frame = 1:step
        for i = 1:size(C,1)
            face = double(C(i,1))-64;
            S1 = S(:,:,face);
            n = str2double(C(i,2));
            switch C(i,3)
                case 'r'
                    for j = 1:d
                        S1{n,j} = (RM(angle)*S1{n,j}')';
                    end
                case 'c'
                    for j = 1:d
                        S1{j,n} = (RM(angle)*S1{j,n}')';
                    end
                case 'x'
                    for j = 1:d^2
                        S1{j} = (RM(angle)*S1{j}')';
                    end
            end
            S(:,:,face) = S1;
        end  

        hold off
        for i=1:6
            for j = 1:d^2
                s = S(:,:,i);
                r = R(:,:,i);
                fill3(s{j}(:,1),s{j}(:,2),s{j}(:,3),map(r(j),:))
                hold on
            end
        end
        axis([-1 1 -1 1 -1 1]*d/sqrt(2))
        set(gca,'CameraPosition',campos,'View',view)
        set(gcf,'Name','Rubik')
        axis off
        axis square
        hold off        
        pause(0.01)
    end    
    if nargout == 1
        varargout{1} = rubrot(Rbackup,move);
    end
else
    if nargout == 1
        varargout{1} = Rbackup;
    end
end

end

function S = rubcoord(d)
%
% Returns the vertex coordinates of each patch that makes up the cube (in
% correct order to be compatible with the fill-function.
%

S = cell(d,d,6);
faces = 'ABCDEF';

for i = 1:6                 %for all faces
    s = S(:,:,i);
    c = zeros(4,3);
    face = faces(i);
    switch face
        case 'A'
            c(:,1) = d;
            for j = 1:d^2
                s{j} = c;
                s{j}(:,2) = [0 0 1 1] + (ceil(j/d)-1);
                s{j}(:,3) = [d d-1 d-1 d] - mod(j-1,d);
                s{j} = s{j}-d/2;
            end
        case 'B'
            c(:,2) = d;
            for j = 1:d^2
                s{j} = c;
                s{j}(:,3) = [d d-1 d-1 d] - mod(j-1,d);
                s{j}(:,1) = [d d d-1 d-1] - (ceil(j/d)-1);
                s{j} = s{j}-d/2;
            end 
        case 'C'
            c(:,1) = 0;
            for j = 1:d^2
                s{j} = c;
                s{j}(:,2) = [d d d-1 d-1] - (ceil(j/d)-1);
                s{j}(:,3) = [d d-1 d-1 d] - mod(j-1,d);   
                s{j} = s{j}-d/2;
            end
        case 'D'
            c(:,2) = 0;
            for j = 1:d^2
                s{j} = c;
                s{j}(:,3) = [d d-1 d-1 d] - mod(j-1,d);
                s{j}(:,1) = [0 0 1 1] + (ceil(j/d)-1);
                s{j} = s{j}-d/2;
            end           
        case 'E'
            c(:,3) = d;
            for j = 1:d^2
                s{j} = c;
                s{j}(:,2) = [0 0 1 1] + (ceil(j/d)-1);
                s{j}(:,1) = [0 1 1 0] + mod(j-1,d);
                s{j} = s{j}-d/2;
            end
        case 'F'
            c(:,3) = 0;
            for j = 1:d^2
                s{j} = c;
                s{j}(:,2) = [0 0 1 1] + (ceil(j/d)-1);
                s{j}(:,1) = [d d-1 d-1 d] - mod(j-1,d);
                s{j} = s{j}-d/2;
            end
    end
    S(:,:,i) = s;
end

end

function C = rubrotcoord(d)
%
% Returns information about which of the coordinates are subject to the
% rotation and thus have to be subjected to the rotation matrices.
%

C = cell(d,3);
d = num2str(d);
C{1,1}   = ['Cxx';['B' d 'c'];'D1c';'E1r';['F' d 'r']];
C{1,2}   = ['Dxx';'A1c';['C' d 'c'];'E1c';'F1c'];
C{1,3}   = ['Exx';'A1r';'B1r';'C1r';'D1r'];
C{end,1} = ['Axx';'B1c';['D' d 'c'];['E' d 'r'];'F1r'];
C{end,2} = ['Bxx';['A' d 'c'];'C1c';['E' d 'c'];['F' d 'c']];
C{end,3} = ['Fxx';['A' d 'r'];['B' d 'r'];['C' d 'r'];['D' d 'r']];

d = str2double(d);
for i = 2:d-1
    x1 = num2str(i);
    x2 = num2str(d-(i-1));
    C{i,1} = [['B' x2 'c'];['D' x1 'c'];['E' x1 'r'];['F' x2 'r']];
    C{i,2} = [['A' x1 'c'];['C' x2 'c'];['E' x1 'c'];['F' x1 'c']];
    C{i,3} = [['A' x1 'r'];['B' x1 'r'];['C' x1 'r'];['D' x1 'r']];
end

if d==1
    C{1,1} = [C{1,1};'Cxx'];
    C{1,2} = [C{1,2};'Dxx'];
    C{1,3} = [C{1,3};'Exx'];
end

end