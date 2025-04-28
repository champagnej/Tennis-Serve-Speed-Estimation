function speed_estimates = parabolic_estimation_filtering(filtered_clusters, corners, frame_rate)
% PARABOLIC_ESTIMATION_FILTERING Estimates speed using parabolic curve fitting.
% Inputs:
%   filtered_clusters - Structure array containing trajectory data for clusters.
%   corners           - Structure containing court corner data for transformation.
%   frame_rate        - Frame rate of the video (e.g., 30 FPS).
% Outputs:
%   speed_estimates   - Array of speed estimates for each cluster.

    % Initialize output array
    num_clusters = length(filtered_clusters);
    speed_estimates = NaN(1, num_clusters);  

    % Loop through each cluster
    for cluster_idx = 1:num_clusters
        cluster = filtered_clusters(cluster_idx);

        % Extract trajectory data
        trajectory = [cluster.Trajectory.X; cluster.Trajectory.Y]';
        frames = [cluster.Trajectory.Frame]';
        current_corners = corners{frames};

        % % Process each cluster using the new function
        % speed_estimates(cluster_idx) = process_cluster(cluster, corners, frame_rate);
        speed_estimates(cluster_idx) = process_cluster(trajectory, frames, current_corners);
    end
end











% function speed_estimates = parabolic_estimation_filtering(filtered_clusters, corners, frame_rate)
% % PARABOLIC_ESTIMATION_FILTERING Estimates speed using parabolic curve fitting.
% % Inputs:
% %   filtered_clusters - Structure array containing trajectory data for clusters.
% %   corners           - Structure containing court corner data for transformation.
% % Outputs:
% %   speed_estimates   - Array of speed estimates for each cluster.
% 
%     % Initialize output array
%     num_clusters = length(filtered_clusters);
%     speed_estimates = NaN(1, num_clusters);
% 
%     % Loop through each cluster
%     for cluster_idx = 1:num_clusters
%         cluster = filtered_clusters(cluster_idx);
% 
%         % Extract trajectory data
%         trajectory = [cluster.Trajectory.X; cluster.Trajectory.Y]';
%         frames = [cluster.Trajectory.Frame]';
% 
%         % Check if trajectory has sufficient points for fitting
%         if size(trajectory, 1) < 3
%             continue; % Skip if not enough points
%         end
% 
%         % Map trajectory to real-world coordinates using corners
%         frame_indices = cluster.Start_Frame:cluster.End_Frame;
%         real_world_points = [];
% 
%         for i = 1:length(frame_indices)
%             frame_idx = frame_indices(i);
% 
%             if frame_idx <= length(corners) && ~isempty(corners{frame_idx})
%                 current_corners = corners{frame_idx};
% 
%                 if istable(current_corners)
%                     image_points = [current_corners.x, current_corners.y];
%                 else
%                     image_points = current_corners;
%                 end
% 
%                 tform = fitgeotform2d(image_points, [
%                     -5.485, 11.885; % Dimension in court (m)
%                      5.485, 11.885;
%                      5.485, -11.885;
%                     -5.485, -11.885
%                 ], 'projective');
% 
%                 real_world_point = transformPointsForward(tform, trajectory(i, :)); % Makes assumption height is parallel to the ground
%                 real_world_points = [real_world_points; real_world_point];
%             end
%         end
% 
%         % Perform parabolic curve fitting (external function)
%         Time = frames / frame_rate; % Time in seconds (s)
%         [coefficients, R_squared] = fit_parabolic_curve(Time, real_world_points(:, 2));
% 
%         % Validate fit and calculate speed
%         if R_squared >= 0.9
%             v_y = 2 * coefficients(1) * Time + coefficients(2); % Velocity in y-direction
%             speed_estimates(cluster_idx) = mean(abs(v_y)); % Speed (m/s)
%         end
%     end
% end