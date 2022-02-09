function varargout = rubinfo(R,varargin)
%
% Returns information about the cube:
% R itself
% d, the dimension of R
% TCorners, the top-cornerpieces of R
% TEdges, the top-edgepieces of R
% BCorners, the bottom-cornerpieces of R
% TCornersEnd, the top-cornerpieces in a solved state
%
% The function proves usefull in the solving method.

if nargout~=nargin-1 && nargout~=0
    error('Number of input parameters does not match number of outputs');
end

d = size(R,1);
Tcorners = zeros(4,3);
TCornersEnd = zeros(4,3);
Bcorners = zeros(4,3);
TEdges = zeros(4,2);
colors = zeros(1,6);

for i=1:4
    c = [2,1,d,d,d;3,d,d,1,d;4,d,1,1,1;1,1,1,d,1];
    Bcorners(i,:) = [R(d,d,i),R(d,1,c(i,1)),R(c(i,2),c(i,3),6)];    %colors of current bottom corners
    Tcorners(i,:) = [R(1,d,i),R(1,1,c(i,1)),R(c(i,4),c(i,5),5)];    %colors of current top corners
    if mod(d,2)==1
        m = ceil(d/2);
        e = [d,m;m,d;1,m;m,1];
        TCornersEnd(i,:) = [R(m,m,i),R(m,m,c(i,1)),R(m,m,5)];
        TEdges(i,:) = [R(1,2,i),R(e(i,1),e(i,2),5)];
    else
        TCornersEnd = NaN;
    end 
end
for i=1:6
    if mod(d,2)==1
        m = ceil(d/2);
        colors(i)  = R(m,m,i);          %facecolors
    else
        colors = NaN;
    end
end
R1 = struct('R',R,...
            'd',size(R,1),...
            'TCorners',Tcorners,...
            'BCorners',Bcorners,...
            'FaceColors',colors,...
            'TCornersEnd',TCornersEnd,...
            'TEdges',TEdges...
            );

switch nargin
    case 1
        varargout{1} = R1;
    otherwise
        for i=1:nargout
            varargout{i} = eval(['R1.' varargin{i}]);
        end
end
end