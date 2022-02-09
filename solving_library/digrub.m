function varargout = digrub(varargin)
%%
%#ok<*NUSED>
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
%#ok<*AGROW>
%#ok<*CTCH>
 
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @digrub_OpeningFcn, ...
                   'gui_OutputFcn',  @digrub_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function digrub_OpeningFcn(hObject, eventdata, handles, varargin) 
%%
handles.output = hObject;

guidata(hObject, handles);

global R
global Log
global help
global scramble

addpath('src','db');
scramble = '-';
help = false;
Log = {};
R=rubgen(3,0);
set(handles.popuprow,'String',{'1','3'})
set(handles.EditDim,'String','3')
set(handles.EditScramble,'String','0')
rubplot(R);
axis off
axis square


function varargout = digrub_OutputFcn(hObject, eventdata, handles) 
%%
varargout{1} = handles.output;


function SaveButton_ClickedCallback(hObject, eventdata, handles)
%%
global Log 
global R
global scramble

[fname path] = uiputfile('*.rub');
if fname==0
    return
end
save([path fname],'R','Log','scramble')


function OpenButton_ClickedCallback(hObject, eventdata, handles)
%%
global Log
global R
global scramble

[fname path] = uigetfile('*.rub');
if fname==0
    return
end
load([path fname],'-mat');
rubplot(R);
d = size(R,1);
if ~isempty(Log)
    temp = Log;
    n = numel(temp);
    temp = char(temp)';
    temp(end+1,:) = [char(44*ones(1,n-1)),' '];
    temp = temp(:)';
    temp(temp==' ') = [];
else
    temp = '-';
end
switch d
    case 1
        options = 'None';
    case 2
        options = {'God''s Algorithm';'Inverse Scramble'};        
    case 3
        options = {'Thistlethwaite 45';'Layer by Layer';'Inverse Scramble'};
    case 4
        options = {'423T45','Inverse Scramble'};
    otherwise
        options = 'Inverse Scramble';
end
set(handles.MethodMenu,'String',options)
if d<=3
    set(handles.fbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.bbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.lbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.rbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.ubutton,'ForegroundColor',[130 130 130]/255);
    set(handles.dbutton,'ForegroundColor',[130 130 130]/255);
else
    set(handles.fbutton,'ForegroundColor',[0 0 0]);
    set(handles.bbutton,'ForegroundColor',[0 0 0]);
    set(handles.lbutton,'ForegroundColor',[0 0 0]);
    set(handles.rbutton,'ForegroundColor',[0 0 0]);
    set(handles.ubutton,'ForegroundColor',[0 0 0]);
    set(handles.dbutton,'ForegroundColor',[0 0 0]);
end
set(handles.StaticLog,'String',temp)
set(handles.StaticScramble,'String',scramble)
set(handles.TextMessage,'String','')
set(handles.DispInfo,'Value',0)
set(handles.EditDim,'String',num2str(d))


function GenBut_Callback(hObject, eventdata, handles)
%%
global R
global Log
global scramble

d = str2double(get(handles.EditDim,'String'));
a = get(handles.RandScramble,'Value');
set(handles.TextMessage,'String','')
set(handles.DispInfo,'Value',0)
if isnan(d)
    errordlg('Please enter the dimension!')
elseif d>20
    errordlg('Dimension is restricted to a value <=20')
    set(handles.EditDim,'String','20')
    return
end
switch d
    case 1
        options = 'None';
    case 2
        options = {'God''s Algorithm';'Inverse Scramble'};        
    case 3
        options = {'Thistlethwaite 45';'Layer by Layer';'Inverse Scramble'};
    case 4
        options = {'423T45','Inverse Scramble'};
    otherwise
        options = 'Inverse Scramble';
end
if d<=3
    set(handles.fbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.bbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.lbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.rbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.ubutton,'ForegroundColor',[130 130 130]/255);
    set(handles.dbutton,'ForegroundColor',[130 130 130]/255);
else
    set(handles.fbutton,'ForegroundColor',[0 0 0]);
    set(handles.bbutton,'ForegroundColor',[0 0 0]);
    set(handles.lbutton,'ForegroundColor',[0 0 0]);
    set(handles.rbutton,'ForegroundColor',[0 0 0]);
    set(handles.ubutton,'ForegroundColor',[0 0 0]);
    set(handles.dbutton,'ForegroundColor',[0 0 0]);
end
set(handles.MethodMenu,'Value',1);
set(handles.MethodMenu,'String',options);
if a==1
    s = str2double(get(handles.EditScramble,'String'));
    set(handles.EditTextScramble,'String','')
    if isnan(s)
        errordlg('Please enter the number of scramble moves.')
        return
    end    
else
    s = get(handles.EditTextScramble,'String');
    if isempty(s)
        errordlg('Please enter scramble sequence')
        return
    end
    s = readsequence(s);
end

anim = get(handles.CheckAnim,'Value');
[R,scramble] = rubgen(d,s,'Animate',anim);
if ~isempty(scramble{1})
    if any('xyz'==scramble{1}(1)) && d<5
        scramble = move2rub(scramble,d);
    elseif ~any('xyz'==scramble{1}(1)) && d>4
        scramble = rub2move(scramble,d);
    end
    for i=1:numel(scramble)-1
        scramble{i}(end+1) = ',';
    end
    scramble = char(scramble')';
    scramble = scramble(:)';
    if isempty(scramble)
        scramble = '-';
    end
else
    scramble = '-';
end
dispscram = get(handles.CheckScramble,'Value');
if dispscram
    if isfloat(s)
        if s==0
            set(handles.StaticScramble,'String','-')
        else
            set(handles.StaticScramble,'String',scramble)
        end
    else
        set(handles.StaticScramble,'String',scramble)
    end
end
rubplot(R);

Log = {};
set(handles.StaticLog,'String','-')
set(handles.Radio1,'Value',1)
set(handles.Radio2,'Value',0)
set(handles.EditMove,'String','')

list = cell(d,1);
for i = 1:d
    list{i} = num2str(i);
end
if d==3
    list = {'1','3'};
end
set(handles.popuprow,'String',list,'Value',1)


function EditDim_Callback(hObject, eventdata, handles)
%%
d = str2double(get(handles.EditDim,'String'));
set(handles.MethodMenu,'Value',1)
if d < 1 || mod(d,1)~=0
    errordlg('The dimension must be a scalar, larger of equal to 1')
    set(handles.EditDim,'String','3');
elseif d > 5 && get(handles.CheckAnim,'Value') && get(handles.RandScramble)
    warndlg('Animation will be toggled off.')
    set(handles.CheckAnim,'Value',0)
    set(handles.CheckRot,'Value',0)
end


function PermOrBut_Callback(hObject, eventdata, handles)
%%
global R
global scramble
global Log

Rbackup = R;
d = size(R,1);
if d~=3 
    ui = questdlg('This feature is only available for 3x3x3 cubes. If choose to continue, your cube will be lost. Continue?','Continue?','Yes','No','Yes');
    switch ui
        case 'Yes'
            R = rubgen(3,0);
            rubplot(R)
            Rbackup = R;
            scramble = '-';
            Log = [];
            set(handles.StaticScramble,'String',scramble)
            set(handles.StaticLog,'String','-')
            set(handles.EditDim,'String','3')
            set(handles.TextMessage,'String','')
        case 'No'
            return
    end
end    

prompt = {'Corner-Permutation:';...
          'Corner-Orientations:';...
          'Edge-Permutation:';...
          'Edge-Orientations:'};

done = false;
while ~done     
    C = GetCorners(R);
    E = GetEdges(R);     
    for i=1:2
        def{i} = [];
        for j=1:8
            def{i} = [def{i},num2str(C(i,j)),','];
        end
        def{i}(end) = [];
    end
    for i=3:4
        def{i} = [];
        for j=1:12
            def{i} = [def{i},num2str(E(i-2,j)),','];
        end
        def{i}(end) = [];
    end
    title = 'Enter State';
    CE = inputdlg(prompt,title,1,def);
    if isempty(CE)
        return
    end
    for i=1:4
        delim = CE{i}==',';
        x = diff([0 find(delim) numel(delim)+1])-1;
        n = numel(x);
        for j=1:n
            z = j+sum(x(1:j))-x(j);
            X{i}(j) = str2double(CE{i}(z:z+x(j)-1));
        end
    end
    if numel(X{1})~=8 || numel(X{2})~=8 || numel(X{3})~=12 || numel(X{4})~=12
        errordlg('Invalid input')
        return
    end
    C = [X{1};X{2}];
    E = [X{3};X{4}];
    R = GetFacelets(C,E);
    set(handles.TextMessage,'String','Validating state...')
    pause(0.01)
    valid = rubcheck(R);
    if ~valid
        set(handles.TextMessage,'String','Invalid state!')
        ui = questdlg('The state you entered is invalid!','Invalid state','Continue anyway','Edit','Cancel','Edit');
        switch ui
            case 'Continue anyway'
                done = true;
            case 'Edit'
                R = Rbackup;
                done = false;
            case 'Cancel'
                R = Rbackup;
                done = true;
        end
    else
        done = true;
    end
end
scramble = 'Unknown';
Log = {};

set(handles.StaticLog,'String','No log available yet')
set(handles.StaticScramble,'String','Unknown')
set(handles.EditDim,'String','3')
set(handles.EditScramble,'String','')
set(handles.TextMessage,'String','')
set(handles.DispInfo,'Value',0)
rubplot(R)



function EditDim_CreateFcn(hObject, eventdata, handles)
%%
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function EditScramble_Callback(hObject, eventdata, handles)
%%
n = str2double(get(handles.EditScramble,'String'));
if n < 0 || mod(n,1)~=0
    errordlg('The dimension must be a positive scalar or zero.')
    set(handles.EditScramble,'String','0');
elseif n > 20 && get(handles.CheckAnim,'Value')
    warndlg('Animation will be toggled off.')
    set(handles.CheckAnim,'Value',0)
end
set(handles.RandScramble,'Value',1)
set(handles.PreScramble,'Value',0)


function EditScramble_CreateFcn(hObject, eventdata, handles)
%%
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function CheckAnim_Callback(hObject, eventdata, handles)
%%
anim = get(handles.CheckAnim,'Value');
d = str2double(get(handles.EditDim,'String'));
s = str2double(get(handles.EditScramble,'String'));

if isempty(d)
    d = 0;
end
if isempty(s)
    s = 0;
end

if (anim==1 && (d>5 || s>20)) && get(handles.RandScramble,'Value')
    errordlg('For animation, set Dimension<=5 and number of scramble moves<=20.')
    set(handles.CheckAnim,'Value',0)
end


function ToggleRotate_Callback(hObject, eventdata, handles)
%%
func = get(handles.ToggleRotate,'String');
switch func
    case '3D-view'
        rotate3d
    case 'Capture'
        uiresume
        return
end


function EditState_Callback(hObject, eventdata, handles)
%%
global R
global Rbackup
global scramble

d = size(R,1);
if d~=2 && d~=3 && d~=4
    errordlg('This feature is only available for dimension=2,3,4.')
    return
end

ui = questdlg(...
'Warning: Editing the state might result in an impossible, thus insolvable, state. Continue?',...
'Continue?','Yes','No','Yes');
if strcmp(ui,'Yes')
    done = false;
    while ~done
        R = editstate(R);
        d = size(R,1);
        if d==3
            R = ruborient(R,'default');
        end
        if d==2 || d==3
            set(handles.TextMessage,'String','Validating state...')
            pause(0.01)
            valid = rubcheck(R);
            if d~=size(R,1)
                change = true;
            else           
                change = ~all(R(:)==Rbackup(:));
            end
            if ~valid
                set(handles.TextMessage,'String','Invalid state!')
                ui = questdlg('The state you entered is invalid!','Invalid state','Continue anyway','Edit','Cancel','Edit');
                switch ui
                    case 'Continue anyway'
                        done = true;
                        scramble = 'Unknown';
                    case 'Edit'
                        done = false;
                    case 'Cancel'
                        R = Rbackup;
                        done = true;
                end
            elseif valid && change
                scramble = 'Unknown';
                done = true;
            else
                done = true;
            end
        else
            scramble = 'Unknown';
            done = true;
        end
    end
    rubplot(R)
else
    return;
end
if get(handles.CheckScramble,'Value')
    set(handles.StaticScramble,'String',scramble)
end
d = size(R,1);
movelist = cell(d,1);
for i = 1:d

    movelist{i} = num2str(i);
end
switch d
    case 1
        options = 'None';
    case 2
        options = {'God''s Algorithm';'Inverse Scramble'};
    case 3
        options = {'Thistlethwaite 45';'Layer by Layer';'Inverse Scramble'};
    case 4
        options = {'423T45','Inverse Scramble'};
    otherwise
        options = 'Inverse Scramble';
end
if d<=3
    set(handles.fbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.bbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.lbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.rbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.ubutton,'ForegroundColor',[130 130 130]/255);
    set(handles.dbutton,'ForegroundColor',[130 130 130]/255);
else
    set(handles.fbutton,'ForegroundColor',[0 0 0]);
    set(handles.bbutton,'ForegroundColor',[0 0 0]);
    set(handles.lbutton,'ForegroundColor',[0 0 0]);
    set(handles.rbutton,'ForegroundColor',[0 0 0]);
    set(handles.ubutton,'ForegroundColor',[0 0 0]);
    set(handles.dbutton,'ForegroundColor',[0 0 0]);
end

set(handles.popuprow,'Value',1,'String',movelist)
set(handles.TextMessage,'String','');
set(handles.StaticLog,'String','-')
set(handles.EditDim,'String',num2str(d))
set(handles.MethodMenu,'Value',1)
set(handles.MethodMenu,'String',options)


function PushButton(button, handles)
%%
global R
global Log

d = size(R,1);

if any('fblrud'==button) && d<4
    return
end

a = get(handles.CheckRot,'Value');
x = get(handles.ccbutton,'Value');
y = get(handles.doublebutton,'Value');

move = button;
if x
    move = [move ''''];
elseif y
    move = [move '2'];
end
R = rubrot(R,rub2move(move,d),'Animate',a);
rubplot(R)
if d>4
    move = rub2move(move,d);
end
Log{end+1} = move;
Log = rubopt(Log,d);
if ~isempty(Log)
    temp = Log;
    n = numel(temp);
    temp = char(temp)';
    temp(end+1,:) = [char(44*ones(1,n-1)),' '];
    temp = temp(:)';
    temp(temp==' ') = [];
else
    temp = '-';
end
set(handles.StaticLog,'String',temp)

        
%% MOVE-BUTTONS
function Fbutton_Callback(hObject, eventdata, handles)
%%
PushButton('F',handles);
function Bbutton_Callback(hObject, eventdata, handles)
%%
PushButton('B',handles);
function Lbutton_Callback(hObject, eventdata, handles)
%%
PushButton('L',handles);
function Rbutton_Callback(hObject, eventdata, handles)
%%
PushButton('R',handles);
function Ubutton_Callback(hObject, eventdata, handles)
%%
PushButton('U',handles);
function Dbutton_Callback(hObject, eventdata, handles)
%%
PushButton('D',handles);
function fbutton_Callback(hObject, eventdata, handles)
%%
PushButton('f',handles);
function bbutton_Callback(hObject, eventdata, handles)
%%
PushButton('b',handles);
function lbutton_Callback(hObject, eventdata, handles)
%%
PushButton('l',handles);
function rbutton_Callback(hObject, eventdata, handles)
%%
PushButton('r',handles);
function ubutton_Callback(hObject, eventdata, handles)
%%
PushButton('u',handles);
function dbutton_Callback(hObject, eventdata, handles)
%%
PushButton('d',handles);


function doublebutton_Callback(hObject, eventdata, handles)
%%
a = get(handles.doublebutton,'Value');
b = get(handles.ccbutton,'Value');
if a && b
    set(handles.ccbutton,'Value',0);
end


function ccbutton_Callback(hObject, eventdata, handles)
%%
a = get(handles.doublebutton,'Value');
b = get(handles.ccbutton,'Value');
if a && b
    set(handles.doublebutton,'Value',0);
end


function popupdir_Callback(hObject, eventdata, handles)
%%
set(handles.Radio1,'Value',1)
set(handles.Radio2,'Value',0)


function popupdir_CreateFcn(hObject, eventdata, handles)
%%
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function popuprow_Callback(hObject, eventdata, handles)
%%
set(handles.Radio1,'Value',1)
set(handles.Radio2,'Value',0)


function popuprow_CreateFcn(hObject, eventdata, handles)
%%
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function popupnum_Callback(hObject, eventdata, handles)
%%
set(handles.Radio1,'Value',1)
set(handles.Radio2,'Value',0)


function popupnum_CreateFcn(hObject, eventdata, handles)
%%
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function RotBut_Callback(hObject, eventdata, handles)
%%
global R
global Log

a = get(handles.Radio1,'Value');
set(handles.TextMessage,'String','')
set(handles.DispInfo,'Value',0)
anim = get(handles.CheckRot,'Value');
d = size(R,1);

if a==1
    dir = get(handles.popupdir,'Value')+119;
    row = str2double(get(handles.popuprow,'String'));
    row = row(get(handles.popuprow,'Value'));
    num = get(handles.popupnum,'Value');
    move = [char(dir),num2str(row),num2str(num)];
else
    move = readsequence(get(handles.EditMove,'String'));
    if isempty(move{1})
        return;
    elseif numel(move{1})<3
        move = rub2move(move,d);
    end
    if d==3 && iscell(move)
        for i=1:numel(move)
            if move{i}(2:end-1)=='2'
                errordlg('Middle piece is not allowed to move.')
                return
            end
        end
    elseif d==3
        if move(2:end-1)=='2'
            errordlg('Middle piece is not allowed to move.')
            return
        end
    end
end

R = rubrot(R,move,'animate',anim);
if ~anim
    rubplot(R);
end

if d<5
    move = move2rub(move,d);
end
if iscell(move)
    Log(end+1:end+numel(move)) = move;
else
    Log{end+1} = move;
end
Log = rubopt(Log,d);
if ~isempty(Log)
    temp = Log;
    n = numel(temp);
    temp = char(temp)';
    temp(end+1,:) = [char(44*ones(1,n-1)),' '];
    temp = temp(:)';
    temp(temp==' ') = [];
else
    temp = '-';
end
set(handles.StaticLog,'String',temp)


function UndoButton_Callback(hObject, eventdata, handles)
%%
global R
global Log

d = size(R,1);
anim = get(handles.CheckRot,'Value');
set(handles.DispInfo,'Value',0)
if isempty(Log)
    return
end
if d<5
    Log = rub2move(Log,d);
end
if iscell(Log)
    lastmove = Log{end};
    Log = Log(1:end-1);
else
    lastmove = Log;
    Log = {};
end
a = [3 2 1];
undomove = lastmove(1:end-1);
undomove(end+1) = num2str(a(str2double(lastmove(end))));
R = rubrot(R,undomove,'animate',anim);
if ~anim
    rubplot(R);
end
if ~isempty(Log)
    if d<5
        Log = move2rub(Log,d);
    end
    temp = Log;
    n = numel(temp);
    temp = char(temp)';
    temp(end+1,:) = [char(44*ones(1,n-1)),' '];
    temp = temp(:)';
    temp(temp==' ') = [];
    set(handles.StaticLog,'String',temp)
else
    set(handles.StaticLog,'String','-')
end


function CheckRot_Callback(hObject, eventdata, handles)
%%
d = str2double(get(handles.EditDim,'String'));
if isempty(d)
    d = 0;
end

if get(handles.CheckRot,'Value') && d>5
    errordlg('Animation only if Dimension<=5')
    set(handles.CheckRot,'Value',0)
end



function OrientBut_Callback(hObject, eventdata, handles)
%%
global R

anim = get(handles.CheckRot,'Value');
R = ruborient(R,'default','Animate',anim);
set(handles.DispInfo,'Value',0)


function RandScramble_Callback(hObject, eventdata, handles)
%%
a = get(handles.PreScramble,'Value');
set(handles.PreScramble,'Value',~a)



function PreScramble_Callback(hObject, eventdata, handles)
%%
a = get(handles.RandScramble,'Value');
set(handles.RandScramble,'Value',~a)


function EditTextScramble_Callback(hObject, eventdata, handles)
%%
set(handles.RandScramble,'Value',0)
set(handles.PreScramble,'Value',1)


function EditTextScramble_CreateFcn(hObject, eventdata, handles)
%%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EditMove_Callback(hObject, eventdata, handles)
%%
test = get(handles.EditMove,'String');
if isempty(test)
    return
else
    set(handles.Radio1,'Value',0)
    set(handles.Radio2,'Value',1)
end


function EditMove_CreateFcn(hObject, eventdata, handles)
%%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Radio1_Callback(hObject, eventdata, handles)
%%
a = get(handles.Radio2,'Value');
set(handles.Radio2,'Value',~a)


function Radio2_Callback(hObject, eventdata, handles)
%%
a = get(handles.Radio1,'Value');
set(handles.Radio1,'Value',~a)


function ClearBut_Callback(hObject, eventdata, handles)
%%
global R
global Log
global help
global scramble

scramble = '-';
help = false;
list = {'1','3'};

Log = {};
set(handles.RandScramble,'Value',1)
set(handles.PreScramble,'Value',0)
set(handles.EditTextScramble,'String','')
set(handles.EditDim,'String','3')
set(handles.EditScramble,'String','0')
set(handles.CheckAnim,'Value',0)
set(handles.AnimSol,'Value',0)
set(handles.Radio1,'Value',1)
set(handles.Radio2,'Value',0)
set(handles.popupdir,'Value',1)
set(handles.popuprow,'String',list,'Value',1)
set(handles.popuprow,'Value',1)
set(handles.popupnum,'Value',1)
set(handles.EditMove,'String','')
set(handles.CheckRot,'Value',0)
set(handles.StaticScramble,'String','-')
set(handles.StaticLog,'String','-')
set(handles.TextMessage,'String','');
set(handles.CheckScramble,'Value',1)
set(handles.DispInfo,'Value',0)
set(handles.MethodMenu,'Value',1)
set(handles.fbutton,'ForegroundColor',[130 130 130]/255);
set(handles.bbutton,'ForegroundColor',[130 130 130]/255);
set(handles.lbutton,'ForegroundColor',[130 130 130]/255);
set(handles.rbutton,'ForegroundColor',[130 130 130]/255);
set(handles.ubutton,'ForegroundColor',[130 130 130]/255);
set(handles.dbutton,'ForegroundColor',[130 130 130]/255);
R = rubgen(3,0);
rubplot(R)


function WebcamButton_Callback(hObject, eventdata, handles)
%%
global R 
global scramble
global Log

try
    info = imaqhwinfo;
catch 
    errordlg('Webcam aquisition not supported.')
    return
end
adaptor = info.InstalledAdaptors;
x = zeros(1,numel(adaptor));
for i = 1:numel(x)
    try 
        vid = videoinput(adaptor{i}, 1); %#ok<TNMLP>
        x(i) = 1;
        delete(vid);
    catch
        continue
    end
end
if nnz(x)==0
    errordlg('No video input device found');
    set(handles.ToggleRotate,'String','3D-view')
    return
end

if strcmp(get(gcf,'Name'),'Rubik')
    DefCam = get(gca,'CameraPosition');
    DefView = get(gca,'View');
else
    DefCam = [33.12 11.73 10.74];
    DefView = [109.5,17.5];
end
Rbackup = R;
set(handles.ToggleRotate,'String','Capture','Style','pushbutton');
set(handles.DispInfo,'Value',0)
adaptor = adaptor{find(x,1)};

q = 0.5;
succes = false;
col = zeros(6,3);
R = cell(1,6);
face = 'FRBLUD';
facecol = {'Red','Blue','Orange','Green','White','Yellow'};
for side = 1:6
    while ~succes
        %%CAPTURE PICTURE FROM WEBCAM
        vid = videoinput(adaptor, 1); %#ok<TNMLP>
        vidRes = get(vid, 'VideoResolution');
        nBands = get(vid, 'NumberOfBands');
        hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
        preview(vid,hImage)
        message = {'White = Up';sprintf('Click ''Capture'' button to capture side: %s (%s)',facecol{side},face(side))};
        set(handles.TextMessage,'String',message);
        uiwait
        img = getsnapshot(vid);
        delete(vid)

        %Find Cube in picture by finding horizontal/vertical edges in 'ed'
        try
            ed = edge(rgb2gray(img));

            x = zeros(size(ed,1),1);
            for i=1:numel(x)
                x(i) = nnz(ed(i,:)); 
            end
            y = zeros(size(ed,2),1);
            for i=1:numel(y)
                y(i) = nnz(ed(:,i)); 
            end

            xpeeks = findpeeks(x);
            ypeeks = findpeeks(y);
            highx  = sort(xpeeks(1,:),'descend');
            highy  = sort(ypeeks(1,:),'descend');
            highx  = highx(1:4);
            highy  = highy(1:4);
            for i=1:4
                posx(i) = xpeeks(2,find(xpeeks(1,:)==highx(i),1));
                posy(i) = ypeeks(2,find(ypeeks(1,:)==highy(i),1));
                xpeeks(:,xpeeks(1,:)==highx(i)) = [];
                ypeeks(:,ypeeks(1,:)==highy(i)) = [];
            end
            posx = sort(posx);
            posy = sort(posy);

            img = img(posx(1):posx(4),posy(1):posy(4),:);
            s = size(img);
            
            %centre the cube image in a square
            if s(1)~=s(2)
                dif = abs(s(1)-s(2));
                cut = ceil(dif/2);
                if s(2)<s(1)
                    img = img(cut:end-cut,:,:);
                else
                    img = img(:,cut:end-cut,:);
                end
                s = size(img);
                img = img(1:min(s(1:2)),1:min(s(1:2)),:);
            end
            
            image(img); axis off square
            cont = false;
            while ~cont
                ui = questdlg('Is this correct?','Confirm','Yes','No','Yes');
                cont = true;
                switch ui
                    case 'Yes'
                        succes = true;
                    case 'No'
                        succes = false;
                end
            end
        catch
            message = 'Failed capturing cube image, please try again';
            set(handles.TextMessage,'String',message)
            pause(1)
        end
    end
    R{side} = img;
    succes = false;
end

for side = 1:6
    s = size(R{side},1);
    x = round(1:(s-1)/3:s);
    R0 = R{side}(x(2):x(3),x(2):x(3),:);
    l = size(R0,1);
    a = round(l/2*(1-sqrt(q)));
    R0 = R0(a:end-a,a:end-a,:);
    R1 = double(R0(:,:,1))/255;
    R2 = double(R0(:,:,2))/255;
    R3 = double(R0(:,:,3))/255;
    col(side,:) = median([R1(:) R2(:) R3(:)]);
end

r = cell(6,1);
for side = 1:6
    s = size(R{side},1);
    x = round(1:(s-1)/3:s);
    for i=1:3
        for j=1:3
            R0 = R{side}(x(i):x(i+1),x(j):x(j+1),:);
            l = size(R0,1);
            a = round(l/2*(1-sqrt(q)));
            R0 = R0(a:end-a,a:end-a,:);
            R1 = double(R0(:,:,1))/255;
            R2 = double(R0(:,:,2))/255;
            R3 = double(R0(:,:,3))/255;
            for k=1:6
                temp = [abs(R1(:)-col(k,1)),...
                        abs(R2(:)-col(k,2)),...
                        abs(R3(:)-col(k,3))];
                D(k) = median(sqrt(sum(temp.^2,2)));
            end
            r{side}(i,j) = find(D==min(D));
        end
    end
    r{side}(2,2) = side;
end

R = cat(3,r{1},r{2},r{3},r{4},r{5},r{6});
done = false;

while ~done
    valid = rubcheck(R);
    if ~valid
        ui = questdlg('The state appears not to have been captured correctly.',...
            'Error capturing state','Edit state manually','Cancel','Edit state manually');
        switch ui
            case 'Edit state manually'
                R = editstate(R);
            otherwise
                R = Rbackup;
                break
        end
    else
        done = true;
        scramble = 'Unknown';
    end
end
set(handles.ToggleRotate,'String','3D-view','Style','togglebutton');
set(handles.TextMessage,'String','');
if get(handles.CheckScramble,'Value')
    set(handles.StaticScramble,'String',scramble)
end
if done
    ruborient(R,'default');
    Log = {};
    set(handles.StaticLog,'String','-')
    set(handles.popuprow,'String',{'1','3'})
    set(handles.EditDim,'String','3')
    helpdlg('Please check if the cube-state was correctly captured.')
else
    set(gca,'CameraPosition',DefCam,'View',DefView);
    rubplot(R);
end


function ManualButton_Callback(hObject, eventdata, handles)
%%
global R
global scramble

Rbackup = R;
done = false;
retry = false;

while ~done
    if retry
        R = editstate(R);
    else
        R = editstate;
    end
    if R==0
        R = Rbackup;
        rubplot(R)
        return
    end
    d = size(R,1);
    if d==3
        R = ruborient(R,'default');
    end
    if d==3 || d==2
        set(handles.TextMessage,'String','Validating state...')
        pause(0.01)
        solved = true;
        valid = rubcheck(R);
        for i=1:6
            solved = solved*all(all(R(:,:,i)==R(2,2,i)));        
        end
        if ~valid
            set(handles.TextMessage,'String','Invalid state!')
            ui = questdlg('The state you entered is invalid!','Invalid state','Continue anyway','Edit','Cancel','Edit');
            switch ui
                case 'Continue anyway'
                    done = true;
                    scramble = 'Unknown';
                case 'Edit'
                    retry = true;
                case 'Cancel'
                    R = Rbackup;
                    done = true;
            end
        else
            done = true;
            scramble = 'Unknown';
        end
    else
        done = true;
        scramble = 'Unknown';
    end
end
rubplot(R)
movelist = cell(d,1);
for i = 1:d
    movelist{i} = num2str(i);
end
switch d
    case 1
        options = 'None';
    case 2
        options = {'God''s Algorithm';'Inverse Scramble'};
    case 3
        options = {'Thistlethwaite 45';'Layer by Layer';'Inverse Scramble'};
    case 4
        options = {'423T45','Inverse Scramble'};
    otherwise
        options = 'Inverse Scramble';
end
if d<=3
    set(handles.fbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.bbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.lbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.rbutton,'ForegroundColor',[130 130 130]/255);
    set(handles.ubutton,'ForegroundColor',[130 130 130]/255);
    set(handles.dbutton,'ForegroundColor',[130 130 130]/255);
else
    set(handles.fbutton,'ForegroundColor',[0 0 0]);
    set(handles.bbutton,'ForegroundColor',[0 0 0]);
    set(handles.lbutton,'ForegroundColor',[0 0 0]);
    set(handles.rbutton,'ForegroundColor',[0 0 0]);
    set(handles.ubutton,'ForegroundColor',[0 0 0]);
    set(handles.dbutton,'ForegroundColor',[0 0 0]);
end

set(handles.popuprow,'String',movelist,'Value',1)
set(handles.TextMessage,'String','');
set(handles.StaticLog,'String','-')
set(handles.EditDim,'String',num2str(d))
set(handles.MethodMenu,'Value',1,'String',options)
set(handles.StaticScramble,'String',scramble)


function CheckScramble_Callback(hObject, eventdata, handles)
%%
global scramble

x = get(handles.CheckScramble,'Value');
if x
    set(handles.StaticScramble,'String',scramble);
else
    set(handles.StaticScramble,'String','Scramble hidden, check the box to display current scramble')
end
    


function SolveButton_Callback(hObject, eventdata, handles)
%%
global R
global Log
global scramble

R0 = R;
d = size(R,1);
a = get(handles.AnimSol,'Value');
b = get(handles.MethodMenu,'Value');
method = get(handles.MethodMenu,'String');
if iscell(method)
    method = method{b};
end
set(handles.DispInfo,'Value',0)
Rtest = R;
if d==3 || d==2
    valid = rubcheck(Rtest);
    if ~valid
        errordlg('Error solving cube: invalid state.')
        message = 'Invalid state';
        set(handles.TextMessage,'String',message)
        return
    end
end
solved = true;
if mod(d,2)==1
    for i=1:6
        solved = solved * all(all(Rtest(:,:,i)==Rtest(ceil(d/2),ceil(d/2),i)));
    end
else
    for i=1:6
        solved = solved * all(all(R(:,:,i)==R(1,1,i)));
    end
end
if solved
    set(handles.TextMessage,'String','Solved!')
    return
end
switch method
    case 'Thistlethwaite 45'
        tic
        solution = Solve45(R);
        time = toc;
        solution = rubopt(solution);
        nmoves = numel(solution);
        message = {sprintf('Elapsed time: %s seconds',num2str(round(time*100)/100));...
                   sprintf('Number of moves: %d',nmoves)};
        set(handles.TextMessage,'String',{'Solved!';message{1};message{2}})
        R = rubrot(R0,rub2move(solution),'Animate',a);
    case 'Layer by Layer'
        [R,solution,time,nmoves] = rubsolve(R);
        message = {sprintf('Elapsed time: %s seconds',num2str(round(time*100)/100));...
                   sprintf('Number of moves: %d',nmoves)};
        set(handles.TextMessage,'String',{'Solved!';message{1};message{2}})
	if a
            rubplot(R0,solution);
	end
        solution = move2rub(solution);
    case 'God''s Algorithm'
        tic
        [rot,solution] = Solve222(R);
        time = toc;
        nmoves = numel(solution);
        message = {sprintf('Elapsed time: %s seconds',num2str(round(time*100)/100));...
                   sprintf('Number of moves: %d',nmoves)};
        set(handles.TextMessage,'String',{'Solved!';message{1};message{2}})
        solution = algrot(solution,rot);
        R = rubrot(R,solution,'Animate',a);
    case '423T45'
        tic
        solution = Solve444(R);
        time = toc;
        nmoves = numel(solution);
        message = {sprintf('Elapsed time: %s seconds',num2str(round(time*100)/100));...
                   sprintf('Number of moves: %d',nmoves)};
        set(handles.TextMessage,'String',{'Solved!';message{1};message{2}})
        sol2 = rub2move(solution,4);
        R = rubrot(R,sol2,'Animate',a);
    case 'Inverse Scramble'
        if scramble=='-'
            warndlg('Cube wasn''t scrambled. Use ''Undo'' to undo the moves.');
            return
        end
        s = scramble;
        s(s==' ') = [];
        s = readsequence(s);

        if ~isempty(Log)
            ui = questdlg(['You already performed moves, you have to undo '... 
                           'these before the inverse scramble can be applied.'],...
                           'Undo Moves?','Undo All','Cancel','Cancel');
            switch ui
                case 'Undo All'
                    R = rubgen(d,s);
                    rubplot(R)
                    Log = {};
                    set(handles.StaticLog,'String','-')
                    return
                case 'Cancel'
                    return
            end
        end        
        if d < 5
            s = rub2move(s,d);
            if ischar(s)
                s = {s};
            end
        end
        invscram = cell(1,numel(s));
        for i=1:numel(s)
            temp = s{i};
            x = str2double(temp(end));
            temp(end) = num2str(abs(x-4));
            invscram{i} = temp;
        end
        solution = invscram(end:-1:1);
        R = rubrot(R0,solution,'Animate',a);
        if d<5
            solution = move2rub(solution,d);
        end
end

rubplot(R)
ui = questdlg('Do you want to view the solution algorithm?','View solution','Yes','No','Yes');
if strcmp(ui,'Yes')
    fname = tempname;
    scramble(scramble==' ') = [];
    if ~strcmp(scramble,'Unknown')
        nscramble = num2str(numel(readsequence(scramble)));
    else
        nscramble = '?';
    end
    method = get(handles.MethodMenu,'String');
    if iscell(method)
        method = method{b};
    end
    if isempty(fname)
        errordlg('File could not be opened.')
        return
    end
    fid = fopen(fname,'w');
    fprintf(fid,'-------------------------------------------------------------------------\n');
    fprintf(fid,'This is a temporary file, use ''Save As'' to save the solution to a file.\n');
    fprintf(fid,'-------------------------------------------------------------------------\n\n');
    fprintf(fid,'Generated by ''digrub.m'', a Rubik''s Cube simulator by Joren Heit (c)\n\n');
    fprintf(fid,'Cube Dimension: %d\n',d);
    fprintf(fid,'Solving Method: %s\n\n',method);
    fprintf(fid,'Scramble (%s moves):\n',nscramble);
    if ~strcmp(scramble,'Unknown')
        scr = readsequence(scramble);
        count = 0;
        for i=1:numel(scr)-1
            fprintf(fid,'%s,',scr{i});
            count = count + numel(scr{i})+1;
            if count>72
                count = 0;
                fprintf(fid,'\n');
            end
        end
        fprintf(fid,'%s',scr{end});
    else
        fprintf(fid,'Unknown');
    end
    if ~isempty(Log)
        fprintf(fid,'\n\nLog:\n');
        count = 0;
        for i=1:numel(Log)-1
            fprintf(fid,'%s,',Log{i});
            count = count + numel(Log{i})+1;
            if count>72
                count = 0;
                fprintf(fid,'\n');
            end
        end
        fprintf(fid,'%s',Log{end});
    end
    fprintf(fid,'\n\nSolution (%d moves):\n',numel(solution));
    count = 0;
    for i=1:numel(solution)-1
        fprintf(fid,'%s,',solution{i});
        count = count + numel(solution{i})+1;
        if count>72
            count = 0;
            fprintf(fid,'\n');
        end
    end
    fprintf(fid,'%s',solution{end});
    fclose(fid);
    open(fname)
end


function AnimSol_Callback(hObject, eventdata, handles)
%%
a = get(handles.AnimSol,'Value');
d = str2double(get(handles.EditDim,'String'));
if a && d>5
    errordlg('Dimension is set too high for animation.')
    a = false;
end
set(handles.AnimSol,'Value',a)


function MethodMenu_Callback(hObject, eventdata, handles)
%%
global scramble

a = get(handles.MethodMenu,'Value');
method = get(handles.MethodMenu,'String');
if iscell(method)
    method = method{a};
end
if strcmp(method,'Inverse Scramble') && strcmp(scramble,'Unknown')
    errordlg('The scramble of this cube is unknown, so no inverse scramble can be applied.')
    set(handles.MethodMenu,'Value',1)
    return
end


function MethodMenu_CreateFcn(hObject, eventdata, handles)
%%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DispInfo_Callback(hObject, eventdata, handles)
%%
global h %#ok<NUSED>

a = get(handles.DispInfo,'Value');
d = str2double(get(handles.EditDim,'String'));
if ~a
    for i=1:12*d
        eval(sprintf('delete(h.t%d);',i))
    end
else
    d = str2double(get(handles.EditDim,'String'));
    q = (mod(d,2)==0) + 1;
    p = [0, 1/2];
    r{1} = (1-d)/2:(d-1)/2;
    r{2} = (1-d)/2:(d-1)/2;
    r{3} = (d-1)/2:-1:(1-d)/2;    
    c = [0 0 0];
    count = 1;
    for i=1:3                   %for x,y,z
        for j=1:4               %for U/D and L/R
            if any(j==[1 2])
                c(1:3~=i) = [-p(q) (-1)^(j+1)*d/2];
                if i==3
                    c(1:2) = c(2:-1:1);
                end
            else
                c(1:3~=i) = [(-1)^(j+1)*d/2 +p(q)];
                 if i==3
                     c(1:2) = c(2:-1:1);
                     c(1) = -c(1);
                 end
            end
            for k=1:d           %for all numbers
                c(i) = r{i}(k);
                eval(sprintf('h.t%d = text(c(1),c(2),c(3),num2str(k));',count))
                count = count+1;
            end
        end
    end
end


function about_ClickedCallback(hObject, eventdata, handles)

msgbox({'Thanks for downloading!';'Created by Joren Heit';'jorenheit@gmail.com';...
        '';'I would like to thank Herbert Kociemba, Jaap Scherphuis and Morwen Thistlethwaite himself for being of great help to this project!';...
           'Please also visit their websites:';...
           'www.jaapsch.net';'www.kociemba.org';...
           'www.math.utk.edu/~morwen/'},'About','none')
       

