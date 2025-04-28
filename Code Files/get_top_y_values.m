function result = get_top_y_values(trajectory,size_thresh)
    
    % Trim to where size is greater than the size of a tennis ball to be
    % sure it doesn't accidentally track that
    % 1. Compute moving average of trajectory.size
    size_moving_avg = [trajectory.Size];
    % size_moving_avg = movmean(trajectory.Size,2, 'omitnan');
    size_filter = (size_moving_avg > size_thresh);

    % 2. filter out all sizes below threshold size ~ 1000
    trimmed_trajectory = trajectory(size_filter);
    
    top_ys = [trimmed_trajectory.Top_Y];
    [~, idx] = min(top_ys);
    result = struct('Frame', [], 'Y', [], 'X', []);

    frame = trimmed_trajectory(idx).Frame;
    topY = trimmed_trajectory(idx).Top_Y;
    topX = trimmed_trajectory(idx).Top_X;

    result.Frame = frame;
    result.Y = topY;
    result.X = topX;

end
