function [rot sol] = Solve222(R)

load('God222.mat')

rot={'y0','z0'; 'y1','z0';...
     'y0','z1'; 'y1','z1';...
     'y0','z2'; 'y1','z2';...
     'y0','z3'; 'y1','z3';...

     'y2','z0'; 'y3','z0';...
     'y2','z1'; 'y3','z1';...
     'y2','z2'; 'y3','z2';...
     'y2','z3'; 'y3','z3';...

     'x1','z0'; 'x3','z0';...
     'x1','z1'; 'x3','z1';...
     'x1','z2'; 'x3','z2';...
     'x1','z3'; 'x3','z3'};

move = {'R'  ,'F'  ,'D';...
        'R2' ,'F2' ,'D2';...
        'R''','F''','D'''};

C = GetCorners2(R);
t = 1;
while C(1,1)~=1 || C(2,1)~=0
    t = t+1;
    R1 = rubrot2(R,rot(t,:));
    C = GetCorners2(R1);
end

rot = rot(t,:);
i1 = State2Ind(C(1,:));
i2 = State2Ind(C(2,:));
n = find(list1==i1);
m = find(list2==i2);
N = A(n,m);
sol = [];

while N>0
    for i=1:9
        C1 = TwistCorners(C,move{i});
        i1 = State2Ind(C1(1,:));
        i2 = State2Ind(C1(2,:));
        n = find(list1==i1);
        m = find(list2==i2);
        M = A(n,m);
        if M<N
            N = M;
            C = C1;
            sol = [sol move(i)];
            break
        end
    end
end
% disp(sol)