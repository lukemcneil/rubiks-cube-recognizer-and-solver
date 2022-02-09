function seq = readsequence(s)

delim = s==',';
x = diff([0 find(delim) numel(delim)+1])-1;
n = numel(x);
seq = cell(1,n);
t = 1;
for i=1:n
    seq{i} = s(t:t+x(i)-1);
    t = t+x(i)+1;
end