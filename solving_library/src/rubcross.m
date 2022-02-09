function face = rubcross(R,varargin)
%
% Finds out if and if so, where a cross is present on the cube.
% Returns face# if there is a cross present, 0 if not.
%

if size(R,1)~=3
    error('Cube must be 3x3x3')
end

if nargin==1
    FaceCheck = [5 1:4 6];
elseif nargin==2
    FaceCheck = varargin{1};
else
    error('Wrong number of input parameters')
end

crossel = [2 4:6 8];
face = 0;
for i=FaceCheck
    r = R(:,:,i);
    r = r==r(5);
    x = sum(r(crossel));
    if x==5
        face = i;
        return
    end
end
    