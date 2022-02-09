function peeks = findpeeks(x)
%
% Finds peeks in a spectrum. Is used during webcam-capture to determine
% position of the cube.
%

n = numel(x);

locmax = 0;
pos = 0;
count = 1;

for i=1:n
    test = max(locmax(count),x(i));
    if i-pos(count) < n/10 && test>locmax(count)
        locmax(count) = test;
        pos(count) = i;
    elseif i-pos(count) >= n/10
        count = count+1;
        locmax(count) = x(i);
        pos(count) = i;
    end
end
    
peeks = [locmax;pos];