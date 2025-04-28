function [new_b, valid] = check_valid_corner(thresh,a,b)
    thresh_sqrd = thresh^2;
    D = zeros(height(a),height(b));
    for i=1:height(a)
        for j=1:height(b)
            U = a(i,:);
            V = b(j,:);
            D(j,i)=(U(1)-V(1)).^2+(U(2)-V(2)).^2; % Squared distance between pts
        end
    end
    [min_D, idx] = min(D);
    % norm_min_D = min_D./max(D);
    valid = all(min_D < thresh_sqrd);
    if valid
        new_b = zeros(size(b));
        for i=1:length(idx)
            new_b(i,:) = b(idx(i),:);
        end
    else
        new_b=0;
    end
end