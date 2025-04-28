function tracked_clusters = cluster_tracking(ball)
    D_max = 80; % Max allowable distance for matching clusters
    Current_ID = 1; % Unique ID for clusters

    % Initialize tracked_clusters
    tracked_clusters = struct('ID', [], 'Start_Frame', [], 'End_Frame', [], 'Trajectory', [], 'average_speed', []);

    % Initialize active_clusters
    active_clusters = [];

    for frameIdx = 1:length(ball.data)
        currentFrame = ball.data{frameIdx}; % 3xN matrix
        numClusters = size(currentFrame, 2);

        % Extract current clusters
        current_clusters = struct('x', {}, 'y', {}, 'size', {}, 'top_y',{},'top_x',{});
        for clusterIdx = 1:numClusters
            current_clusters(clusterIdx).x = currentFrame(1, clusterIdx);
            current_clusters(clusterIdx).y = currentFrame(2, clusterIdx);
            current_clusters(clusterIdx).size = currentFrame(3, clusterIdx);
            current_clusters(clusterIdx).top_y = currentFrame(4, clusterIdx);
            current_clusters(clusterIdx).top_x = currentFrame(5, clusterIdx);
        end

        if frameIdx == 1
            % Initialize tracked_clusters with clusters from 1st frame
            for clusterIdx = 1:numClusters
                % Calculate Top_Y and Top_X for the first frame
                cluster_y = current_clusters(clusterIdx).y;
                cluster_x = current_clusters(clusterIdx).x;
                top_y = current_clusters(clusterIdx).top_y; % Topmost y
                top_x = current_clusters(clusterIdx).top_x; % Average x for Top_Y
                
                tracked_clusters(Current_ID).ID = Current_ID;
                tracked_clusters(Current_ID).Start_Frame = frameIdx;
                tracked_clusters(Current_ID).End_Frame = NaN; % Undefined
                % Include Top_Y and Top_X in the Trajectory struct
                tracked_clusters(Current_ID).Trajectory = struct('Frame', frameIdx, 'X', current_clusters(clusterIdx).x, ...
                                                                'Y', current_clusters(clusterIdx).y, 'Size', current_clusters(clusterIdx).size, ...
                                                                'Speed', NaN, 'Angle', NaN, 'Change_in_Angle', NaN, ...
                                                                'Absolute_Angle_Change', NaN, 'Top_Y', top_y, 'Top_X', top_x);

                % Update active_clusters
                active_clusters(end+1).ID = Current_ID;
                active_clusters(end).Last_Position = [current_clusters(clusterIdx).x, current_clusters(clusterIdx).y];

                Current_ID = Current_ID + 1;
            end
            continue;
        end

        %% Matching Clusters Between Active Clusters and Current Clusters
        if isempty(active_clusters)
            % No active clusters, assign new IDs to all current clusters
            for clusterIdx = 1:numClusters
                % Calculate Top_Y and Top_X
                cluster_y = current_clusters(clusterIdx).y;
                cluster_x = current_clusters(clusterIdx).x;
                top_y = current_clusters(clusterIdx).top_y;
                top_x = current_clusters(clusterIdx).top_x;
                
                tracked_clusters(Current_ID).ID = Current_ID;
                tracked_clusters(Current_ID).Start_Frame = frameIdx;
                tracked_clusters(Current_ID).End_Frame = NaN;
                tracked_clusters(Current_ID).Trajectory = struct('Frame', frameIdx, 'X', current_clusters(clusterIdx).x, ...
                                                                'Y', current_clusters(clusterIdx).y, 'Size', current_clusters(clusterIdx).size, ...
                                                                'Speed', NaN, 'Angle', NaN, 'Change_in_Angle', NaN, ...
                                                                'Absolute_Angle_Change', NaN, 'Top_Y', top_y, 'Top_X', top_x);

                % Update active_clusters
                active_clusters(end+1).ID = Current_ID;
                active_clusters(end).Last_Position = [current_clusters(clusterIdx).x, current_clusters(clusterIdx).y];

                Current_ID = Current_ID + 1;
            end
            continue; % Move to the next frame
        end

        % Compute distance matrix between active_clusters and current_clusters
        numActive = length(active_clusters);
        distanceMatrix = zeros(numActive, numClusters);

        for a = 1:numActive
            for c = 1:numClusters
                dx = active_clusters(a).Last_Position(1) - current_clusters(c).x;
                dy = active_clusters(a).Last_Position(2) - current_clusters(c).y;
                distanceMatrix(a, c) = sqrt(dx^2 + dy^2); % Use actual distances
            end
        end

        % Initialize matching flags
        matchedActive = zeros(numActive, 1);
        matchedCurrent = zeros(numClusters, 1);

        for a = 1:numActive
            % Find closest current cluster for active cluster 'a'
            [minDist, minIdx] = min(distanceMatrix(a, :));
            if minDist <= D_max && ~matchedCurrent(minIdx)
                % Match found
                matchedActive(a) = 1;
                matchedCurrent(minIdx) = 1;

                % Calculate Top_Y and Top_X
                cluster_y = current_clusters(minIdx).y;
                cluster_x = current_clusters(minIdx).x;
                top_y = current_clusters(minIdx).top_y; % Topmost y
                top_x = current_clusters(minIdx).top_x; % Average x for Top_Y

                % Update tracked_clusters with new position and size
                clusterID = active_clusters(a).ID;
                tracked_clusters(clusterID).Trajectory(end+1) = struct('Frame', frameIdx, 'X', current_clusters(minIdx).x, ...
                                                                      'Y', current_clusters(minIdx).y, 'Size', current_clusters(minIdx).size, ...
                                                                      'Speed', NaN, 'Angle', NaN, 'Change_in_Angle', NaN, ...
                                                                      'Absolute_Angle_Change', NaN, 'Top_Y', top_y, 'Top_X', top_x);

                % Update active_clusters with new position
                active_clusters(a).Last_Position = [current_clusters(minIdx).x, current_clusters(minIdx).y];
            end
        end

        %% Handle Unmatched Current Clusters (New Clusters)
        for c = 1:numClusters
            if ~matchedCurrent(c)
                % Calculate Top_Y and Top_X
                cluster_y = current_clusters(c).y;
                cluster_x = current_clusters(c).x;
                top_y = current_clusters(c).top_y; % Topmost y
                top_x = current_clusters(c).top_x; % Average x for Top_Y


                % Assign new ID to this cluster
                tracked_clusters(Current_ID).ID = Current_ID;
                tracked_clusters(Current_ID).Start_Frame = frameIdx;
                tracked_clusters(Current_ID).End_Frame = NaN;
                tracked_clusters(Current_ID).Trajectory = struct('Frame', frameIdx, 'X', current_clusters(c).x, ...
                                                                'Y', current_clusters(c).y, 'Size', current_clusters(c).size, ...
                                                                'Speed', NaN, 'Angle', NaN, 'Change_in_Angle', NaN, ...
                                                                'Absolute_Angle_Change', NaN, 'Top_Y', top_y, 'Top_X', top_x);

                % Add to active_clusters
                active_clusters(end+1).ID = Current_ID;
                active_clusters(end).Last_Position = [current_clusters(c).x, current_clusters(c).y];

                Current_ID = Current_ID + 1;
            end
        end

        %% Handle Unmatched Active Clusters (Ended Clusters)
        endedClusters = find(~matchedActive);
        for idx = length(endedClusters):-1:1  % Loop backwards when deleting elements
            a = endedClusters(idx);
            % Update End_Frame for the ended cluster
            clusterID = active_clusters(a).ID;
            tracked_clusters(clusterID).End_Frame = frameIdx - 1;
            % Remove ended clusters from active_clusters
            active_clusters(a) = [];
        end
    end

    %% Finalize End_Frames for Remaining Active Clusters
    for a = 1:length(active_clusters)
        clusterID = active_clusters(a).ID;
        tracked_clusters(clusterID).End_Frame = length(ball.data);
    end


    %% Post-processing: Add Speed, Angle, Change_in_Angle, Absolute_Angle_Change Columns, and average_speed
    % Now each cluster has a Trajectory of structs with fields: Frame, X, Y, Size, Speed, Angle, Change_in_Angle, Absolute_Angle_Change.
    for i = 1:length(tracked_clusters)
        traj = tracked_clusters(i).Trajectory;
        if isempty(traj)
            % No trajectory
            tracked_clusters(i).average_speed = NaN;
            continue;
        end

        % Compute speed, angle, change in angle, and absolute angle change for frames from the second struct onwards
        speeds = NaN(1, length(traj));
        angles = NaN(1, length(traj));
        changes_in_angle = NaN(1, length(traj));
        absolute_angle_changes = NaN(1, length(traj));
        for t = 2:length(traj)
            x1 = traj(t-1).X;
            y1 = traj(t-1).Y;
            x2 = traj(t).X;
            y2 = traj(t).Y;
            dx = x2 - x1;
            dy = y2 - y1;

            % Speed calculation
            dist = sqrt(dx^2 + dy^2);
            speeds(t) = dist;
            traj(t).Speed = dist;

            % Angle calculation (in degrees)
            angle = atan2d(dy, dx); % Angle relative to positive X-axis
            angles(t) = angle;
            traj(t).Angle = angle;

            % Change in angle calculation
            prev_angle = traj(t-1).Angle;
            delta_angle = angle - prev_angle;
            % Normalize to range [-180, 180]
            delta_angle = mod(delta_angle + 180, 360) - 180;
            changes_in_angle(t) = delta_angle;
            traj(t).Change_in_Angle = delta_angle;

            % Absolute angle change calculation (sum of magnitudes)
            if t > 2
                abs_change = abs(traj(t-1).Change_in_Angle) + abs(delta_angle);
                absolute_angle_changes(t-1) = abs_change;
                traj(t-1).Absolute_Angle_Change = abs_change;
            end
        end

        % Compute average speed ignoring NaNs
        avg_spd = nanmean(speeds);

        % Update cluster structure
        tracked_clusters(i).Trajectory = traj;
        tracked_clusters(i).average_speed = avg_spd;
    end
end






















% function tracked_clusters = cluster_tracking(ball)
%     D_max = 80; % Max allowable distance for matching clusters
%     Current_ID = 1; % Unique ID for clusters
% 
%     % Initialize tracked_clusters
%     tracked_clusters = struct('ID', [], 'Start_Frame', [], 'End_Frame', [], 'Trajectory', [], 'average_speed', []);
% 
%     % Initialize active_clusters
%     active_clusters = [];
% 
%     for frameIdx = 1:length(ball.data)
%         currentFrame = ball.data{frameIdx}; % 3xN matrix
%         numClusters = size(currentFrame, 2);
% 
%         % Extract current clusters
%         current_clusters = struct('x', {}, 'y', {}, 'size', {});
%         for clusterIdx = 1:numClusters
%             current_clusters(clusterIdx).x = currentFrame(1, clusterIdx);
%             current_clusters(clusterIdx).y = currentFrame(2, clusterIdx);
%             current_clusters(clusterIdx).size = currentFrame(3, clusterIdx);
%         end
% 
%         if frameIdx == 1
%             % Initialize tracked_clusters with clusters from 1st frame
%             for clusterIdx = 1:numClusters
%                 tracked_clusters(Current_ID).ID = Current_ID;
%                 tracked_clusters(Current_ID).Start_Frame = frameIdx;
%                 tracked_clusters(Current_ID).End_Frame = NaN; % Undefined
%                 % Initially no speed, angle, change in angle, or absolute angle change column
%                 tracked_clusters(Current_ID).Trajectory = struct('Frame', frameIdx, 'X', current_clusters(clusterIdx).x, ...
%                                                                 'Y', current_clusters(clusterIdx).y, 'Size', current_clusters(clusterIdx).size, ...
%                                                                 'Speed', NaN, 'Angle', NaN, 'Change_in_Angle', NaN, 'Absolute_Angle_Change', NaN);
% 
%                 % Update active_clusters
%                 active_clusters(end+1).ID = Current_ID;
%                 active_clusters(end).Last_Position = [current_clusters(clusterIdx).x, current_clusters(clusterIdx).y];
% 
%                 Current_ID = Current_ID + 1;
%             end
%             continue;
%         end
% 
%         %% Matching Clusters Between Active Clusters and Current Clusters
%         if isempty(active_clusters)
%             % No active clusters, assign new IDs to all current clusters
%             for clusterIdx = 1:numClusters
%                 tracked_clusters(Current_ID).ID = Current_ID;
%                 tracked_clusters(Current_ID).Start_Frame = frameIdx;
%                 tracked_clusters(Current_ID).End_Frame = NaN;
%                 tracked_clusters(Current_ID).Trajectory = struct('Frame', frameIdx, 'X', current_clusters(clusterIdx).x, ...
%                                                                 'Y', current_clusters(clusterIdx).y, 'Size', current_clusters(clusterIdx).size, ...
%                                                                 'Speed', NaN, 'Angle', NaN, 'Change_in_Angle', NaN, 'Absolute_Angle_Change', NaN);
% 
%                 % Update active_clusters
%                 active_clusters(end+1).ID = Current_ID;
%                 active_clusters(end).Last_Position = [current_clusters(clusterIdx).x, current_clusters(clusterIdx).y];
% 
%                 Current_ID = Current_ID + 1;
%             end
%             continue; % Move to the next frame
%         end
% 
%         % Compute distance matrix between active_clusters and current_clusters
%         numActive = length(active_clusters);
%         distanceMatrix = zeros(numActive, numClusters);
% 
%         for a = 1:numActive
%             for c = 1:numClusters
%                 dx = active_clusters(a).Last_Position(1) - current_clusters(c).x;
%                 dy = active_clusters(a).Last_Position(2) - current_clusters(c).y;
%                 distanceMatrix(a, c) = sqrt(dx^2 + dy^2); % Use actual distances
%             end
%         end
% 
%         % Initialize matching flags
%         matchedActive = zeros(numActive, 1);
%         matchedCurrent = zeros(numClusters, 1);
% 
%         for a = 1:numActive
%             % Find closest current cluster for active cluster 'a'
%             [minDist, minIdx] = min(distanceMatrix(a, :));
%             if minDist <= D_max && ~matchedCurrent(minIdx)
%                 % Match found
%                 matchedActive(a) = 1;
%                 matchedCurrent(minIdx) = 1;
% 
%                 % Update tracked_clusters with new position and size
%                 clusterID = active_clusters(a).ID;
%                 tracked_clusters(clusterID).Trajectory(end+1) = struct('Frame', frameIdx, 'X', current_clusters(minIdx).x, ...
%                                                                       'Y', current_clusters(minIdx).y, 'Size', current_clusters(minIdx).size, ...
%                                                                       'Speed', NaN, 'Angle', NaN, 'Change_in_Angle', NaN, 'Absolute_Angle_Change', NaN);
% 
%                 % Update active_clusters with new position
%                 active_clusters(a).Last_Position = [current_clusters(minIdx).x, current_clusters(minIdx).y];
%             end
%         end
% 
%         %% Handle Unmatched Current Clusters (New Clusters)
%         for c = 1:numClusters
%             if ~matchedCurrent(c)
%                 % Assign new ID to this cluster
%                 tracked_clusters(Current_ID).ID = Current_ID;
%                 tracked_clusters(Current_ID).Start_Frame = frameIdx;
%                 tracked_clusters(Current_ID).End_Frame = NaN;
%                 tracked_clusters(Current_ID).Trajectory = struct('Frame', frameIdx, 'X', current_clusters(c).x, ...
%                                                                 'Y', current_clusters(c).y, 'Size', current_clusters(c).size, ...
%                                                                 'Speed', NaN, 'Angle', NaN, 'Change_in_Angle', NaN, 'Absolute_Angle_Change', NaN);
% 
%                 % Add to active_clusters
%                 active_clusters(end+1).ID = Current_ID;
%                 active_clusters(end).Last_Position = [current_clusters(c).x, current_clusters(c).y];
% 
%                 Current_ID = Current_ID + 1;
%             end
%         end
% 
%         %% Handle Unmatched Active Clusters (Ended Clusters)
%         endedClusters = find(~matchedActive);
%         for idx = length(endedClusters):-1:1  % Loop backwards when deleting elements
%             a = endedClusters(idx);
%             % Update End_Frame for the ended cluster
%             clusterID = active_clusters(a).ID;
%             tracked_clusters(clusterID).End_Frame = frameIdx - 1;
%             % Remove ended clusters from active_clusters
%             active_clusters(a) = [];
%         end
%     end
% 
%     %% Finalize End_Frames for Remaining Active Clusters
%     for a = 1:length(active_clusters)
%         clusterID = active_clusters(a).ID;
%         tracked_clusters(clusterID).End_Frame = length(ball.data);
%     end
% 
%     %% Post-processing: Add Speed, Angle, Change_in_Angle, Absolute_Angle_Change Columns, and average_speed
%     % Now each cluster has a Trajectory of structs with fields: Frame, X, Y, Size, Speed, Angle, Change_in_Angle, Absolute_Angle_Change.
%     for i = 1:length(tracked_clusters)
%         traj = tracked_clusters(i).Trajectory;
%         if isempty(traj)
%             % No trajectory
%             tracked_clusters(i).average_speed = NaN;
%             continue;
%         end
% 
%         % Compute speed, angle, change in angle, and absolute angle change for frames from the second struct onwards
%         speeds = NaN(1, length(traj));
%         angles = NaN(1, length(traj));
%         changes_in_angle = NaN(1, length(traj));
%         absolute_angle_changes = NaN(1, length(traj));
%         for t = 2:length(traj)
%             x1 = traj(t-1).X;
%             y1 = traj(t-1).Y;
%             x2 = traj(t).X;
%             y2 = traj(t).Y;
%             dx = x2 - x1;
%             dy = y2 - y1;
% 
%             % Speed calculation
%             dist = sqrt(dx^2 + dy^2);
%             speeds(t) = dist;
%             traj(t).Speed = dist;
% 
%             % Angle calculation (in degrees)
%             angle = atan2d(dy, dx); % Angle relative to positive X-axis
%             angles(t) = angle;
%             traj(t).Angle = angle;
% 
%             % Change in angle calculation
%             prev_angle = traj(t-1).Angle;
%             delta_angle = angle - prev_angle;
%             % Normalize to range [-180, 180]
%             delta_angle = mod(delta_angle + 180, 360) - 180;
%             changes_in_angle(t) = delta_angle;
%             traj(t).Change_in_Angle = delta_angle;
% 
%             % Absolute angle change calculation (sum of magnitudes)
%             if t > 2
%                 abs_change = abs(traj(t-1).Change_in_Angle) + abs(delta_angle);
%                 absolute_angle_changes(t-1) = abs_change;
%                 traj(t-1).Absolute_Angle_Change = abs_change;
%             end
%         end
% 
%         % Compute average speed ignoring NaNs
%         avg_spd = nanmean(speeds);
% 
%         % Update cluster structure
%         tracked_clusters(i).Trajectory = traj;
%         tracked_clusters(i).average_speed = avg_spd;
%     end
% end
