function varargout = ruborient(R,orientation,varargin)
%
% function to (re)orient the cube. Default orientation is White-Up,
% Red-Front, otherwise specify orientation as a string [UP FRONT], i.e. 'WR' in the default case.
% Can also be used to orient so that a cross is on the Up-face using 'cross'.
%

col = 'RBOGWY';

if strcmp(orientation,'default')
    U = 5;
    F = 1;
elseif strcmp(orientation,'cross')
    face = rubcross(R);
    if face==0
        error('No cross on the cube')
    end
else
    U = find(col==orientation(1));
    F = find(col==orientation(2));
end    

if nargin > 2
    if (strcmp(varargin{1},'Animate')||strcmp(varargin{1},'animate')) && ...
        varargin{2} == 1
        animate = 1;
    else
        animate = 0;
    end
else 
    animate = 0;
end

d = size(R,1);
%get default camera position & view
figure; rubplot(rubgen(d,0));
DefaultCam = get(gca,'CameraPosition');
DefaultView = get(gca,'View');
close

AllOrientations = ...
    {'y0','z0'; 'y1','z0';...
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
    
if mod(d,2)==1
    C = {'y3','x1','y1','x3','x0','x2'};
    Rtemp = R;
    c = ceil(d/2);
    switch orientation
        case 'cross'
            move = C{face};
            R = rubrot2(R,C{x},'animate',animate);
        otherwise            
            done = false;
            for i=1:24
                test = rubrot2(Rtemp,AllOrientations(i,:));
                if test(c,c,1)==F && test(c,c,5)==U
                    move = AllOrientations(i,:);
                    R = rubrot2(R,move,'animate',animate);
                    done = true;
                    break
                end
            end
            if ~done
                error('Impossible orientation')
            end
    end
    del = zeros(numel(move));
    for i=1:numel(move)
        if move{i}(2)=='0'
            del(i) = true;
        end
    end
           
    switch nargout
        case 1
            varargout{1} = R;
        case 2
            varargout{1} = R;
            varargout{2} = move(~del);
    end
    CurCam = round(100*get(gca,'CameraPosition'))/100;
    CurView = round(100*get(gca,'View'))/100;
    if animate && (~all(CurCam==DefaultCam)||~all(CurView==DefaultView))
        step = 10;
        MoveCam = DefaultCam-CurCam;
        MoveView = DefaultView-CurView;
        x = zeros(step+1,3);
        y = zeros(step+1,2);
        x(:,1) = DefaultCam(1);x(:,2) = DefaultCam(2);x(:,3) = DefaultCam(3);
        y(:,1) = DefaultView(1);y(:,2) = DefaultView(2);
        for i=find(MoveCam)
            x(:,i) = CurCam(i):MoveCam(i)/step:DefaultCam(i);
        end
        for i=find(MoveView)
            y(:,i) = CurView(i):MoveView(i)/step:DefaultView(i);
        end
        for i=1:step+1
            set(gca,'CameraPosition',x(i,:),'View',y(i,:))
            pause(0.01)
        end
    elseif strcmp(orientation,'default')
        set(gca,'CameraPosition',DefaultCam,'View',DefaultView);
    end
else
    switch nargout
        case 1
            varargout{1} = R;
        case 2
            varargout{1} = R;
            varargout{2} = move(~del);
    end
    CurCam = round(100*get(gca,'CameraPosition'))/100;
    CurView = round(100*get(gca,'View'))/100;
    if animate && (~all(CurCam==DefaultCam)||~all(CurView==DefaultView))
        step = 10;
        MoveCam = DefaultCam-CurCam;
        MoveView = DefaultView-CurView;
        x = zeros(step+1,3);
        y = zeros(step+1,2);
        x(:,1) = DefaultCam(1);x(:,2) = DefaultCam(2);x(:,3) = DefaultCam(3);
        y(:,1) = DefaultView(1);y(:,2) = DefaultView(2);
        for i=find(MoveCam)
            x(:,i) = CurCam(i):MoveCam(i)/step:DefaultCam(i);
        end
        for i=find(MoveView)
            y(:,i) = CurView(i):MoveView(i)/step:DefaultView(i);
        end
        for i=1:step+1
            set(gca,'CameraPosition',x(i,:),'View',y(i,:))
            pause(0.01)
        end
    elseif strcmp(orientation,'default')
        set(gca,'CameraPosition',DefaultCam,'View',DefaultView);
    end
end
if strcmp(orientation,'default')
    rubplot(R);
end