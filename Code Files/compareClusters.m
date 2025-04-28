function [newx, newy, idx, distance] = compareClusters(size,x,y,prevsize,prevx,prevy,sizethresh)
    
    if (isequal(prevx,0) && isequal(prevy,0) && isequal(prevsize,0))
        % Reorder x and y to put them in order  in terms of size
        [~, new_clusters] = sort(size, 'ascend');
        newx = x(new_clusters);
        newy = y(new_clusters);
        idx=-1;
        distance = 0;
        return
    end
    new_clusters = zeros(1,length(x));
    prevx=prevx(1:length(x));
    prevy=prevy(1:length(y));
    for i=1:length(x)
        pt1=[x(i) y(i)];
        list=[prevx;prevy]';
        new_clusters(i) = mindist(pt1,list);
    end
    newx = x(new_clusters);
    newy = y(new_clusters);
    newsize = size(new_clusters);
    idx=-1;
    distance=0;
    return
end