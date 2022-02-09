function X = Ind2State(Y,TYPE)
%
% Converts an index to corresponding state (CO,CP, EO, EP).
%
if TYPE(1)=='C'
    n = 8;
    v = 3;
elseif TYPE(1)=='E'
    n = 12;
    v = 2;
else
    error('Unknown TYPE')
end

if TYPE(2)=='O'
    s = 0;
    X = zeros(1,n);
    for i = n-1:-1:1
        X(i) = mod(Y,v);
        s = s-X(i);
        if s<0
            s = s+v;
        end
        Y = (Y-X(i))/v;
    end
    X(n) = s;    
elseif TYPE(2)=='P'    
    X = zeros(1,n);
    X(n) = 1;
    for i = n-1:-1:1
        X(i) = 1 + mod(Y,n-i+1);
        Y = (Y-mod(Y,n-i+1))/(n-i+1);
        for j = i+1:n
            if X(j) >= X(i)
                X(j) = X(j)+1;
            end
        end
    end
else
    error('Unknown TYPE')
end