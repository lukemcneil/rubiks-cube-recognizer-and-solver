function [R varargout] = rubgen(d,n,varargin)
%
% Syntax:  [R, scramble] = rubgen(d,n)
% Generates Rubik's cube of dimension d. n can be an integer to specify the
% number of random moves applied to scramble the cube, or a prespecified
% sequence in the form of a string cell (using axile code). 
%
% Example:
% [R,scramble] = rubgen(3,23);
% will generate a 3x3x3 cube and apply a 23-move random scramble.
%
% The scrambling can be animated by setting handle 'Animate' to 'true'.
% For special purposes, the default is an output in which the cube
% faces each have their own ID-number instead of a color-number. By setting
% R = rubgen(3,23,'Color'), R will have color-numbers 1-6.
%
% Example:
% [R,scramble] = rubgen(3,23,'Color','Animate',1);
% Will animate the 23-scramble process on a 3x3x3 cube and store the
% endresult in R and the scramble in 'scramble'.


R  = zeros(d,d,6);
R(:) = ceil((1:6*d^2)/d^2);
if d<=4
    type = 'rubik';     %default code-types
else
    type = 'axile';
end

if isfloat(n)  && numel(n)==1
    seq = genmove(n,d);
    N = 0;
    while N~=n
        temp = rubopt(seq,d);
        N = size(temp,2);
        if N~=n
            seq = [temp genmove(n-N,d)];
        end
    end
else
    if ischar(n)
        if numel(n)==3
            type = 'axile';
        else
            type = 'rubik';
            n = rub2move(n,d);
        end
        seq = {n};
    elseif iscell(n)
        if numel(n{1})<=2
            type = 'rubik';
            n = rub2move(n,d);            
        else
            type = 'axile';
        end
        seq = n;
    else
        error('Unknown sequence form')
    end    
end

if isempty(seq)
    seq = {'x10'};
end

%%GENERATE APPROPRIATE OUTPUT
if nargin==2
    R = rubrot(R,seq);
elseif nargin==4
    x = strcmp(varargin{1},'Animate') + strcmp(varargin{1},'animate');
    if x
        switch varargin{2}
            case 1
                R = rubplot(R,seq);
            case 0
                R = rubrot(R,seq);
            otherwise
                error('Value for Animate must be set to either 0 or 1')
        end
    else
        error('Unknown handle')
    end
else
    error('Wrong number of input parameters')
end

if nargout==2
    switch type
        case 'axile'
            varargout{1}=seq;
        case 'rubik'
            varargout{1}=move2rub(seq,d);
    end
end


function seq = genmove(n,d)

% generates sequence of n random moves for cube of dimension d

dir = round(2*rand(1,n))+120;
row = round((d-1)*rand(1,n))+1;
num = round(2*rand(1,n))+1;
if d==3     %avoid generating middle piece rotations
    row = d*round(rand(1,n));
    row(row==0) = 1;    % row = 1,d 
end
temp = cell(1,n);
for i=1:n
    move = num2str(10^(numel(num2str(row(i)))+1));
    move(1) = char(dir(i));
    move(2:end-1) = num2str(row(i));
    move(end) = num2str(num(i));
    temp{i} = move;
end
seq = temp;
