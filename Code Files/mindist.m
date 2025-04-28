function [index, dist] = mindist(pt1, list)
    output = zeros(1,size(list,1));
    for j=1:size(list,1)
        pt2 = list(j,:);
        output(j)=(pt1(1)-pt2(1)).^2+(pt1(2)-pt2(2)).^2; % Squared distance between pts
    end
    [dist, index] = min(output);
end
