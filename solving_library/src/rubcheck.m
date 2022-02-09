function valid = rubcheck(R)
%
% Check the validity of a cube state R (for d = 2 or 3)
%
d = size(R,1);

if d==3
    try
        C = GetCorners(R);
        E = GetEdges(R);
    catch %#ok<CTCH>
        valid = false;
        return
    end
elseif d==2
    try
        C = GetCorners2(R);
    catch %#ok<CTCH>
        valid = false;
        return
    end
end

h = hist(R(:),1:6);
if ~all(h==d^2)
    valid = false;
    return
end

if d==3
    par = mod(parity(C(1,:))+parity(E(1,:)),2);
    x = mod(nnz(E(2,:)),2);
    y = mod(sum(C(2,:)),3);
    if par==0 && x==0 && y==0
        valid = true;
    else
        valid = false;
    end
elseif d==2
    x = mod(sum(C(2,:)),3);
    if  x==0
        valid = true;
    else
        valid = false;
    end
else
    valid = false;
end


function p = parity(x)

n = 0;
m = length(x);
for i=1:m
    j = find(x==i);
    if j~=m
        n = n+nnz(x(j+1:end)<i);
    end
end

p = mod(n,2);