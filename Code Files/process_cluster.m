function speed = process_cluster(trajectory, frames, current_corners)
% PROCESS_CLUSTER Estimates the speed of a single trajectory using parabolic curve fitting.
% Inputs:
%   trajectory      - Array of [X, Y] positions for the trajectory.
%   frames          - Array of frame indices corresponding to the trajectory points.
%   current_corners - Smoothed corner data for mapping to real-world coordinates.
% Outputs:
%   speed           - Speed estimate for the trajectory (m/s), or NaN if fitting fails.

    % Check if trajectory has sufficient points for fitting
    if size(trajectory, 1) < 3
        speed = NaN; % Not enough points for parabolic fitting
        return;
    end

    % Perform parabolic curve fitting (external function)
    Time = frames / 30; % Assuming frame rate is 30 FPS
    [coefficients, R_squared] = fit_parabolic_curve(Time, trajectory);

    % Validate fit and calculate speed
    if R_squared >= 0.9
        v_y = 2 * coefficients(1) * Time + coefficients(2); % Velocity in y-direction
        speed = mean(abs(v_y)); % Speed (m/s)
    else
        speed = NaN; % Fit did not meet quality threshold
    end



    % Map trajectory to real-world coordinates using current corners
    real_world_points = [];

    if istable(current_corners)
        image_points = [current_corners.x, current_corners.y];
    else
        image_points = current_corners;
    end

    tform = fitgeotform2d(image_points, [
        -5.485, 11.885;
         5.485, 11.885;
         5.485, -11.885;
        -5.485, -11.885
    ], 'projective');

    for i = 1:size(trajectory, 1)
        real_world_point = transformPointsForward(tform, trajectory(i, :));
        real_world_points = [real_world_points; real_world_point];
    end

end









% 
% 
% function speed = process_cluster(trajectory, frames, current_corners)
% % PROCESS_CLUSTER Estimates the speed of a single trajectory using parabolic curve fitting.
% % Inputs:
% %   trajectory      - Array of [X, Y] positions for the trajectory.
% %   frames          - Array of frame indices corresponding to the trajectory points.
% %   current_corners - Smoothed corner data for mapping to real-world coordinates.
% % Outputs:
% %   speed           - Speed estimate for the trajectory (m/s), or NaN if fitting fails.
% 
%     % Check if trajectory has sufficient points for fitting
%     if size(trajectory, 1) < 3
%         speed = NaN; % Not enough points for parabolic fitting
%         return;
%     end
% 
%     % Map trajectory to real-world coordinates using current corners
%     real_world_points = [];
% 
%     if istable(current_corners)
%         image_points = [current_corners.x, current_corners.y];
%     else
%         image_points = current_corners;
%     end
% 
%     tform = fitgeotform2d(image_points, [
%         -5.485, 11.885;
%          5.485, 11.885;
%          5.485, -11.885;
%         -5.485, -11.885
%     ], 'projective');
% 
%     for i = 1:size(trajectory, 1)
%         real_world_point = transformPointsForward(tform, trajectory(i, :));
%         real_world_points = [real_world_points; real_world_point];
%     end
% 
%     % Perform parabolic curve fitting (external function)
%     Time = frames / 30; % Assuming frame rate is 30 FPS
%     [coefficients, R_squared] = fit_parabolic_curve(Time, real_world_points(:, 1), real_world_points(:, 2));
% 
%     % Validate fit and calculate speed
%     if R_squared >= 0.9
%         v_y = 2 * coefficients(1) * Time + coefficients(2); % Velocity in y-direction
%         speed = mean(abs(v_y)); % Speed (m/s)
%     else
%         speed = NaN; % Fit did not meet quality threshold
%     end
% end
% 



