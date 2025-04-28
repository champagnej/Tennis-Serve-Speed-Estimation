function filtered_clusters = filter_short_clusters(tracked_clusters, min_frames, min_speed)
    % FILTER_SHORT_CLUSTERS Filters out clusters that do not last at least min_frames,
    % meet min_speed, or exceed max_angle_change.
    %
    % Inputs:
    %   - tracked_clusters: Structure array where each entry has fields:
    %       - ID: Unique identifier for the cluster.
    %       - Start_Frame: Frame where the cluster begins.
    %       - End_Frame: Frame where the cluster ends.
    %       - Trajectory: Contains trajectory data for the cluster.
    %       - average_speed: Average speed of the cluster.
    %   - min_frames: Minimum number of frames a cluster must persist.
    %   - min_speed: Minimum average speed the cluster must maintain.
    %   - max_angle_change: Maximum allowable value for Absolute_Angle_Change.
    %
    % Outputs:
    %   - filtered_clusters: Filtered structure array of clusters that meet all criteria.

    % Initialize an empty structure array to store the filtered clusters
    filtered_clusters = struct('ID', {}, 'Start_Frame', {}, 'End_Frame', {}, 'Trajectory', {}, 'average_speed', {});

    % Iterate through each cluster in tracked_clusters
    for i = 1:numel(tracked_clusters)
        % Extract cluster properties
        start_frame = tracked_clusters(i).Start_Frame;
        end_frame = tracked_clusters(i).End_Frame;
        avg_speed = tracked_clusters(i).average_speed;

        % Calculate the lifespan of the cluster
        lifespan = end_frame - start_frame + 1;

        % Check for maximum angle change in trajectory
        exceeds_angle_change = false;
        % for j = 1:length(tracked_clusters(i).Trajectory)
        %     if ~isnan(tracked_clusters(i).Trajectory(j).Absolute_Angle_Change) && tracked_clusters(i).Trajectory(j).Absolute_Angle_Change > max_angle_change
        %         exceeds_angle_change = true;
        %         break;
        %     end
        % end

        % Check if the cluster meets all criteria
        if lifespan >= min_frames && avg_speed >= min_speed && ~exceeds_angle_change
            filtered_clusters(end + 1) = tracked_clusters(i); % good cluster
        end
    end

    % Return two fastest filtered clusters
    [max_vals, idx] = maxk([filtered_clusters(:).average_speed], 2);
    [max_vals, idx] = sort(max_vals, 'ascend');
    filtered_clusters = filtered_clusters(idx);


end
