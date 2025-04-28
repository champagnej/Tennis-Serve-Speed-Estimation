function fastest_per_frame_interp = interpolate_nan_positions(fastest_per_frame)
    % INTERPOLATE_NAN_POSITIONS Linearly interpolate NaN positions (X,Y) in fastest_per_frame.
    %
    % Input:
    %   - fastest_per_frame: Nx4 matrix [Frame, X, Y, ClusterID]
    %     Frames with no cluster: [Frame, NaN, NaN, NaN]
    %
    % Output:
    %   - fastest_per_frame_interp: same as fastest_per_frame, but with NaN positions linearly
    %     interpolated where possible.
    %
    % Interpolation logic:
    %   - Identify runs of consecutive NaN frames between two known points.
    %   - Linearly interpolate X and Y between these known points.
    %   - If ClusterID before and after the gap is the same and not NaN, fill the gap with that ClusterID.
    %   - If IDs differ or are NaN, leave ClusterID as NaN.

    fastest_per_frame_interp = fastest_per_frame;
    if isempty(fastest_per_frame)
        return; % Nothing to interpolate
    end

    frames = fastest_per_frame(:,1);
    X = fastest_per_frame(:,2);
    Y = fastest_per_frame(:,3);
    CID = fastest_per_frame(:,4);

    % Find indices where X and Y are not NaN (known points)
    known = ~isnan(X) & ~isnan(Y);

    % If we have no known points or only one known point, we cannot interpolate
    if sum(known) < 2
        return;
    end

    % We'll scan through frames looking for intervals of NaNs bounded by known points.
    known_idxs = find(known);
    % known_idxs are the indices in fastest_per_frame with valid data

    for i = 1:length(known_idxs)-1
        start_idx = known_idxs(i);
        end_idx = known_idxs(i+1);

        % Check the gap between start_idx and end_idx
        gap_length = (end_idx - start_idx - 1);
        if gap_length > 0
            % We have a gap of frames that might be interpolated
            % Frames: from start_idx+1 to end_idx-1 are NaN currently

            x1 = X(start_idx); y1 = Y(start_idx);
            x2 = X(end_idx);   y2 = Y(end_idx);

            f1 = frames(start_idx);
            f2 = frames(end_idx);

            % Potential clusterID logic:
            % If CID at start and end match and are not NaN, use that CID.
            start_cid = CID(start_idx);
            end_cid = CID(end_idx);
            fill_cid = NaN;
            if ~isnan(start_cid) && ~isnan(end_cid) && start_cid == end_cid
                fill_cid = start_cid;
            end

            for gap_i = start_idx+1:end_idx-1
                f = frames(gap_i);
                % Linear interpolation factor
                alpha = (f - f1) / (f2 - f1);
                X(gap_i) = x1 + (x2 - x1)*alpha;
                Y(gap_i) = y1 + (y2 - y1)*alpha;
                if ~isnan(fill_cid)
                    CID(gap_i) = fill_cid;
                end
            end
        end
    end

    % Update the output with interpolated values
    fastest_per_frame_interp(:,2) = X;
    fastest_per_frame_interp(:,3) = Y;
    fastest_per_frame_interp(:,4) = CID;
end
