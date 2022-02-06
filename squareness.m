function [squareness] = squareness(mask)
    [r, c] = find(mask==1);
    area = size(r, 1);
    squareness = area / ((max(r) - min(r)) * (max(c) - min(c)));
end
