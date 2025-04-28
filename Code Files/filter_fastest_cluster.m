function fastest_per_frame = filter_fastest_cluster(filtered_clusters, min_speed)
    % FILTER_FASTEST_CLUSTER:
    %   1) Filters out clusters that do not exceed min_speed in their average_speed.
    %   2) For each frame, find the cluster with the highest instantaneous speed.
    %   3) Return a matrix: [Frame, X, Y, ClusterID] for each frame.
    %      If no cluster qualifies at a frame, that frame row will have NaNs for X, Y, and ClusterID.
    %
    % Inputs:
    %   - filtered_clusters: Array of clusters with fields:
    %       ID, Start_Frame, End_Frame, Trajectory (with Speed), average_speed
    %   - min_speed: Minimum average speed threshold to keep a cluster
    %
    % Output:
    %   - fastest_per_frame: A [maxFrame x 4] matrix:
    %       [Frame, X, Y, ClusterID]
    %     If no cluster for a frame, X, Y, ClusterID = NaN

    % Step 1: Filter out clusters by average_speed
    % Initialize qualified_clusters as an empty struct array with the same fields
    qualified_clusters = filtered_clusters([]); 

    q_idx = 1;
    for i = 1:length(filtered_clusters)
        if ~isnan(filtered_clusters(i).average_speed) && filtered_clusters(i).average_speed > min_speed
            qualified_clusters(q_idx) = filtered_clusters(i); %#ok<AGROW>
            q_idx = q_idx + 1;
        end
    end

    if isempty(qualified_clusters)
        % No clusters exceed min_speed
        fastest_per_frame = [];
        return;
    end

    % Determine maxFrame from the End_Frame of qualified clusters
    maxFrame = max([qualified_clusters.End_Frame]);

    % Initialize output
    fastest_per_frame = NaN(maxFrame, 4);
    fastest_per_frame(:,1) = (1:maxFrame)'; % Frame numbers

    % Step 2: For each frame, find the fastest cluster (highest instantaneous speed)
    for f = 1:maxFrame
        best_speed = -Inf;
        best_x = NaN;
        best_y = NaN;
        best_id = NaN;

        for i = 1:length(qualified_clusters)
            traj = qualified_clusters(i).Trajectory;
            % traj: [Frame, X, Y, Size, Speed]
            idx = find(traj(:,1) == f, 1);
            if ~isempty(idx)
                speed = traj(idx, 5); % Speed
                if ~isnan(speed) && speed > best_speed
                    best_speed = speed;
                    best_x = traj(idx, 2);
                    best_y = traj(idx, 3);
                    best_id = qualified_clusters(i).ID;
                end
            end
        end

        if best_speed > -Inf
            fastest_per_frame(f, 2) = best_x;
            fastest_per_frame(f, 3) = best_y;
            fastest_per_frame(f, 4) = best_id;
        else
            % remains NaN if no cluster at this frame
        end
    end
end
