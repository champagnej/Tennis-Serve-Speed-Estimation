function fastest_per_frame = filter_by_frames_and_speed(tracked_clusters, min_frames, min_speed)
    % FILTER_BY_FRAMES_AND_SPEED:
    % 1) Filter clusters by minimum frame lifespan using filter_short_clusters.
    % 2) From those, choose the fastest cluster per frame above min_speed using filter_fastest_cluster.
    %
    % Returns a matrix [Frame, X, Y, ClusterID] for each frame.
    % If no cluster qualifies at a particular frame, that row will have NaNs for X, Y, and ClusterID.
    %
    % Inputs:
    %   - tracked_clusters: Structure array from cluster_tracking,
    %     each cluster must have fields: ID, Start_Frame, End_Frame, Trajectory (...), average_speed
    %   - min_frames: Minimum number of frames a cluster must persist
    %   - min_speed: Minimum average speed threshold
    %
    % Output:
    %   - fastest_per_frame: Nx4 matrix with columns [Frame, X, Y, ClusterID]

    % Step 1: Filter short clusters
    filtered_clusters = filter_short_clusters(tracked_clusters, min_frames);

    % Step 2: Get fastest per frame
    fastest_per_frame = filter_fastest_cluster(filtered_clusters, min_speed);
end

%% SUB-FUNCTIONS

function filtered_clusters = filter_short_clusters(tracked_clusters, min_frames)
    % FILTER_SHORT_CLUSTERS Filters out clusters that do not last at least min_frames.
    %
    % Inputs:
    %   - tracked_clusters: Structure array of clusters (ID, Start_Frame, End_Frame, Trajectory, average_speed)
    %   - min_frames: Minimum number of frames a cluster must exist
    %
    % Output:
    %   - filtered_clusters: A subset of tracked_clusters that last at least min_frames frames

    filtered_clusters = struct('ID', {}, 'Start_Frame', {}, 'End_Frame', {}, 'Trajectory', {}, 'average_speed', {});
    idx = 1;
    for i = 1:length(tracked_clusters)
        cluster = tracked_clusters(i);
        lifespan = cluster.End_Frame - cluster.Start_Frame + 1;
        if lifespan >= min_frames
            filtered_clusters(idx) = cluster; %#ok<AGROW>
            idx = idx + 1;
        end
    end
end

function fastest_per_frame = filter_fastest_cluster(filtered_clusters, min_speed)
    % FILTER_FASTEST_CLUSTER:
    % 1) From filtered_clusters, keep only those whose average_speed > min_speed.
    % 2) For each frame from 1 to maxFrame, find the cluster with the highest instantaneous speed.
    % 3) Return a [maxFrame x 4] matrix: [Frame, X, Y, ClusterID].
    %    If no cluster qualifies at a frame, that row will have [Frame, NaN, NaN, NaN].
    %
    % Inputs:
    %   - filtered_clusters: Clusters with at least fields: ID, End_Frame, Trajectory (with Speed), average_speed
    %   - min_speed: Minimum average speed threshold
    %
    % Output:
    %   - fastest_per_frame: Nx4 matrix [Frame, X, Y, ClusterID]

    % Initialize qualified_clusters as empty struct array of same type
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

    % Determine maxFrame
    maxFrame = max([qualified_clusters.End_Frame]);

    % Initialize output
    fastest_per_frame = NaN(maxFrame, 4);
    fastest_per_frame(:,1) = (1:maxFrame)'; % Frame numbers in first column

    % For each frame, find the fastest cluster
    % Trajectory format: [Frame, X, Y, Size, Speed]
    for f = 1:maxFrame
        best_speed = -Inf;
        best_x = NaN;
        best_y = NaN;
        best_id = NaN;

        for i = 1:length(qualified_clusters)
            traj = qualified_clusters(i).Trajectory;
            idx = find(traj(:,1) == f, 1);
            if ~isempty(idx)
                speed = traj(idx, 5); % speed is 5th column
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
        end
    end
end
