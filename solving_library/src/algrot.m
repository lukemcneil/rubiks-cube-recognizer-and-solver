function out = algrot(alg,rot)
%
% Rotates algorithms around the 3 axes x,y,z or reflects them in the planes
% perpendicular to these axes. Only moves specified by
% R(r),L(l),U(u),D(d),F(f),B(b) can be entered.
%

if iscell(rot)
    rot = rot(end:-1:1);
    for i = 1:numel(rot)
        alg = algrot(alg,rot{i});
    end
    out = alg;
    return
end
if iscell(alg)
    out = cell(1,numel(alg));
    for i = 1:numel(alg)
        out{i} = algrot(alg{i},rot);
    end
    return;
end

if any(alg(1)=='xyz')
    if alg(3)=='0'
        out = alg;
        return
    end
    code = 'axile';
    alg  = move2rub(alg);
    alg  = alg{1};
else 
    code = 'rubik';
end

table = ['FBDURLfbdurl';...
         'FBLRDUfblrdu';...
         'FBUDLRfbudlr';...
         'UDRLBFudrlbf';...
         'BFRLDUbfrldu';...
         'DURLFBdurlfb';...
         'LRFBUDlrfbud';...
         'BFLRUDbflrud';...
         'RLBFUDrlbfud';...
         'BFRLUDbfrlud';...
         'FBLRUDfblrud';...
         'FBRLDUfbrldu'];
     
face   = 'FBRLUDfbrlud';

if rot(2)=='0'
    out = alg;
    if strcmp(code,'axile')
        out = rub2move(out);
    end
    return
end
if any('xyz'==rot(1)) %rotations
    rotdir = find('xyz'==rot(1));
    rotnum = str2double(rot(2));
    x = 3*(rotdir-1)+rotnum;
    out = 'xx';
    out(1) = table(x,face==alg(1));
    if numel(alg)==1
        out(2) = [];
    else
        out(2) = alg(2);
        if out(2)=='x'
            out = [];
        elseif out(2)==' ';    
            out = out(1);
        end
    end
    if strcmp(code,'axile')
        out = rub2move(out);
    end
    return
else %reflections
    x = double(rot(2))-110;
    out = table(x,face==alg(1));
    if numel(alg)==1
        out = [out ''''];
    elseif alg(2)=='2'
        out = [out '2'];
    end
end