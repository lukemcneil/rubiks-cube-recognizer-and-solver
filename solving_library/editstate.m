function varargout = editstate(varargin)
%#ok<*NUSED>
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
%#ok<*AGROW>
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @editstate_OpeningFcn, ...
                   'gui_OutputFcn',  @editstate_OutputFcn, ...
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


function editstate_OpeningFcn(hObject, eventdata, handles, varargin)
global map
global R
global Rbackup
global save

map =   [255   0   0;...          %red
           0   0 255;...          %blue    
         255 165   0;...          %orange  
           0 255   0;...          %green
         255 255 255;...          %white
         255 255   0]/255;        %yellow
     
     
handles.output = hObject;

guidata(hObject, handles);

set(gcf,'Name','Edit state');
Rbackup = 0;
save = false;

if nargin==4
    R = varargin{1};
    d = size(R,1);
    set(handles.SetDim,'Value',d)
    Rbackup = R;
    
    side = 'RBOGWY';
    for i=1:6
        for j=1:d
            for k=1:d
                tag = [side(i) num2str(j) num2str(k)];
                col = R(j,k,i);
                eval(sprintf('set(handles.%s,''String'',''%s'')',tag,side(col)))
                eval(sprintf('set(handles.%s,''FontSize'',12)',tag))
                eval(sprintf('set(handles.%s,''FontWeight'',''Bold'')',tag))
                eval(sprintf('set(handles.%s,''BackgroundColor'',[%f,%f,%f])',tag,map(col,1),map(col,2),map(col,3)))
            end
        end
    end
end

uiwait(handles.figure1);

function fillfield(field,color,handles)
global map

if isempty(color)
    eval(sprintf('set(handles.%s,''BackgroundColor'',[1,1,1])',field));
    return
end
eval(sprintf('curcol = get(handles.%s,''BackgroundColor'');',field))
for i=1:3
    y(:,i) = abs(map(:,i)-curcol(i));
end
eps = 1e-3;
y = find(all(y'<eps),1);
if isempty(y)
    eval(sprintf('set(handles.%s,''String'','''')',field))
    return
end
x = find(upper(color(1))=='RBOGWY');     
if isempty(x)
    eval(sprintf('set(handles.%s,''BackgroundColor'',[1,1,1])',field));
    eval(sprintf('set(handles.%s,''String'','''')',field))
    return
end
eval(sprintf('set(handles.%s,''BackgroundColor'',[%f,%f,%f])',field,map(x,1),map(x,2),map(x,3)))
eval(sprintf('set(handles.%s,''String'',''%s'')',field,upper(color(1))))
eval(sprintf('set(handles.%s,''FontSize'',12)',field))
eval(sprintf('set(handles.%s,''FontWeight'',''Bold'')',field))


function SetDim_Callback(hObject, eventdata, handles)

d = get(handles.SetDim,'Value');
side = 'RBOGWY';
for i=1:6
    for j=1:4
        for k=1:4
            tag = [side(i) num2str(j) num2str(k)];
            eval(sprintf('set(handles.%s,''String'','''')',tag))
            eval(sprintf('set(handles.%s,''BackgroundColor'',[%f,%f,%f])',tag,0.831,0.816,0.784))
        end
    end
end
if d==1
    return
end
for i=1:6
    for j=1:d
        for k=1:d
            tag = [side(i) num2str(j) num2str(k)];
            eval(sprintf('set(handles.%s,''BackgroundColor'',[%f,%f,%f])',tag,1,1,1))
            eval(sprintf('set(handles.%s,''String'','''')',tag))
        end
    end
end

function SetDim_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SaveButton_Callback(hObject, eventdata, handles)
global R
global save

d = get(handles.SetDim,'Value');
R = zeros(d,d,6);
side = 'RBOGWY';
for i=1:6
    for j=1:d
        for k=1:d
            tag = [side(i) num2str(j) num2str(k)];
            col = eval(sprintf('get(handles.%s,''String'')',tag));
            if isempty(col)
                errordlg('Please fill in all fields.')
                return
            end
            val = find(side==col);
            R(j,k,i) = val;
        end
    end
end
uiresume(gcf)
save = true;
close(gcf)

function CancelButton_Callback(hObject, eventdata, handles)
global R
global Rbackup

R = Rbackup;
uiresume(gcf)
close(gcf)

function ResetButton_Callback(hObject, eventdata, handles)
global Rbackup
global map

if numel(Rbackup)>1
    R = Rbackup;
else
    R = zeros(3,3,6);
    for i=1:6
        R(2,2,i) = i;
    end
end
d = size(R,1);
set(handles.SetDim,'Value',d)
side = 'RBOGWY';
for i=1:6
    for j=1:4
        for k=1:4
            tag = [side(i) num2str(j) num2str(k)];
            eval(sprintf('set(handles.%s,''String'','''')',tag))
            eval(sprintf('set(handles.%s,''BackgroundColor'',[%f,%f,%f])',tag,0.831,0.816,0.784))
        end
    end
end
for i=1:6
    for j=1:d
        for k=1:d
            tag = [side(i) num2str(j) num2str(k)];
            col = R(j,k,i);
            if col==0
                col = 5;
                label = '';
            else
                label = side(col);
            end
            eval(sprintf('set(handles.%s,''String'',''%s'')',tag,label))
            eval(sprintf('set(handles.%s,''FontSize'',12)',tag))
            eval(sprintf('set(handles.%s,''FontWeight'',''Bold'')',tag))
            eval(sprintf('set(handles.%s,''BackgroundColor'',[%f,%f,%f])',tag,map(col,1),map(col,2),map(col,3)))
        end
    end
end
    

function figure1_CloseRequestFcn(hObject, eventdata, handles)

global save
global R
global Rbackup
if ~save
    R = Rbackup;
end    
delete(hObject);


function varargout = editstate_OutputFcn(hObject, eventdata, handles) 

global R
varargout{1} = R;



%ALL FIELDS
function G11_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G11_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G12_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G12_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G13_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G13_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G21_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G21_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G22_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G22_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G23_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G23_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G31_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G31_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G32_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G32_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G33_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G33_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R11_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R11_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R12_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R12_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R13_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R13_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R21_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R21_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R22_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R22_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R23_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R23_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R31_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R31_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R32_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R32_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R33_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R33_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O11_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O11_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O12_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O12_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O13_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O13_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O21_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O21_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O22_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O22_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O23_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O23_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O31_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O31_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O32_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O32_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O33_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O33_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B11_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B11_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B12_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B12_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B13_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B13_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B21_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B21_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B22_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B22_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B23_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B23_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B31_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B31_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B32_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B32_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B33_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B33_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W11_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W11_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W12_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W12_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W13_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W13_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W21_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W21_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W22_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W22_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W23_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W23_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W31_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W31_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W32_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W32_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W33_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W33_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y11_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y11_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y12_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y12_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y13_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y13_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y21_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y21_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y22_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y22_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y23_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y23_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y31_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y31_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y32_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y32_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y33_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y33_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W41_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W41_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W42_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W42_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W43_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W43_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W14_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W14_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W24_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W24_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W34_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W34_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function W44_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function W44_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G41_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G41_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G42_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G42_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G43_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G43_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G14_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G14_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G24_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G24_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G34_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G34_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G44_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function G44_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R41_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R41_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R42_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R42_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R43_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R43_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R14_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R14_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R24_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R24_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R34_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R34_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R44_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function R44_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y41_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y41_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y42_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y42_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y43_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y43_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y14_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y14_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y24_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y24_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y34_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y34_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y44_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function Y44_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B41_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B41_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B42_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B42_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B43_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B43_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B14_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B14_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B24_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B24_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B34_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B34_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B44_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function B44_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O41_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O41_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O42_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O42_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O43_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O43_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O14_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O14_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O24_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O24_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O34_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O34_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function O44_Callback(hObject, eventdata, handles)

current = get(gco,'Tag');
color = eval(sprintf('get(handles.%s,''String'')',current));
fillfield(current,color,handles);
function O44_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
