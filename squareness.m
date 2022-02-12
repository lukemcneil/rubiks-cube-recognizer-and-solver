function [squareness] = squareness(mask)
    [r, c] = find(mask==1);
    area = size(r, 1);
    squareness = area / ((max(r) - min(r) + 1) * (max(c) - min(c) + 1));
end
