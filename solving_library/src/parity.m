function odd = parity(x)
%
% Calculate parity of an edge permutation
%
n = 0;
for i=1:12
    j = find(x==i);
    if j~=12
        n = n+nnz(x(j+1:end)<i);
    end
end

odd = mod(n,2);