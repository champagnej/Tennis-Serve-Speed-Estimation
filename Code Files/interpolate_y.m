function top_pt = interpolate_y(p1, p2, x)
    x1=p1(1);
    y1=p1(2);
    x2=p2(1);
    y2=p2(2);
    % Ensure x1 and x2 are not the same to avoid division by zero
    if x1 == x2
        error('x1 and x2 cannot be the same; the line must not be vertical.');
    end

    % Compute the slope of the line
    slope = (y2 - y1) / (x2 - x1);

    % Calculate the corresponding y-position using the line equation
    y_pos = y1 + slope * (x - x1);

    % Compute the normalized position between -1 and 1
    norm_position = 2 * ((x - x1) / (x2 - x1)) - 1;

    % Compute x_pos
    x_pos = x;

    top_pt = [x_pos,y_pos];
end
