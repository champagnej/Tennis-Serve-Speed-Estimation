function filtered_player_cluster = filter_top_player_cluster(tracked_clusters, min_frames, max_average_speed, max_average_height, min_x, max_x)
    % Initialize filtered cluster as empty
    filtered_player_cluster = [];
    

    % Loop through each cluster
    for i = 1:length(tracked_clusters)
        cluster = tracked_clusters(i);
        
        % Calculate number of frames the cluster was tracked
        num_frames = cluster.End_Frame - cluster.Start_Frame + 1;
        
        % Skip if cluster doesn't meet minimum frame requirement
        if num_frames < min_frames
            continue;
        end
        
        % Skip if cluster exceeds the maximum average speed
        if cluster.average_speed > max_average_speed
            continue;
        end
        
        % Calculate average height (Y position) from the cluster's trajectory
        trajectory = cluster.Trajectory; % Struct array with X, Y, etc.
        avg_height = mean([trajectory.Y]); % Average Y position
        avg_x      = mean([trajectory.X]);

        % Skip if cluster's average height is greater than the maximum
        if avg_height > max_average_height
            continue;
        end
        
        if (avg_x > max_x || avg_x < min_x)
            continue;
        end
        

        % If all conditions are met, return this cluster
        filtered_player_cluster = cluster;
        return;
    end
    
    % If no valid cluster is found, return empty
    if isempty(filtered_player_cluster)
        warning('No cluster meets the filtering criteria.');
    end
end
