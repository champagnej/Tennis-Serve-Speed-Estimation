close all
clear all
    
% Uncomment to remove duplicate frames and save it as another video
% vid = VideoReader('Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/TennisRallyClip1.mp4');
% 
% % Remove duplicate frames if needed:
% vid_in = 'Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/TennisRallyClip1.mp4';
% vid_out = 'Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/TennisRallyClip1_no_duplicates';
% remove_duplicates(vid_in, vid_out, 20)

% filename = 'Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/Daniil Medvedev v Alex Minaur/Daniil_Clip_1_MPH_128.mp4';



% Make this the file where your tennis video is located
filename = 'Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/Serena_Williams_US_OPEN/Serena_Clip_10_MPH_109.mp4';
frame_rate = 30;



vid = VideoReader(filename);
% vid = VideoReader('Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/TennisClip_2.mp4');

myVideo = VideoWriter('myFile.avi');
open(myVideo)

frameCounter = 0;
max_Frames = 10000;

% while frameCounter <= 12
%     videoFrame = readFrame(vid);
%     frameCounter=frameCounter+1;
% end

prevmask = 0;
mask_array = 0;

% xpos = 664;
% ypos = 37;
% size = 25;


thresh = 2000;

distances   = [];
x_list      = [];
y_list      = [];
sizes_list  = [];
frame_count_list = [];

% corners     = 0;
corners.data = {};


ball_xy_size = 0;

% for i=1:110
%     videoFrame=readFrame(vid);
% end

currentFrame = readFrame(vid);
framesize = size(currentFrame);
framesize = framesize(1:2);
% currentFrame = edge_detect(currentFrame);
nextFrame = readFrame(vid);
% nextFrame = edge_detect(nextFrame);

% if (sum(sum(imabsdiff(currentFrame,nextFrame)>20)))<20
%     nextFrame=readFrame(vid);
%     nextFrame = edge_detect(nextFrame);
% end

ball.data = {};


% While loop computes potential clusters of tennis ball
while hasFrame(vid) && frameCounter <= max_Frames

    prevFrame = currentFrame;
    currentFrame = nextFrame;
    nextFrame = readFrame(vid);
    % nextFrame = edge_detect(nextFrame);
    
    % if (sum(sum(imabsdiff(currentFrame,nextFrame)>20)))<20
    %     nextFrame=readFrame(vid);
    %     nextFrame = edge_detect(nextFrame);
    % end

    if ~exist('details','var')
        % ball_xy_size = find_ball(videoFrame, prevFrame, thresh, 0, corners(:,:,end));
        [details,ball.data{1}] = find_ball2(nextFrame,currentFrame, prevFrame, thresh,{});
    else
        % ball_xy_size(:,end+1) = find_ball(videoFrame, prevFrame, thresh, ball_xy_size, corners(:,:,end));
        [details,ball.data{end+1}] = find_ball2(nextFrame,currentFrame, prevFrame, thresh,details);

    end

    frameCounter = frameCounter + 1;
end

close(myVideo);

tracked_clusters = cluster_tracking(ball);


min_frames = 1 * 30; % The player should be consistently tracked across many frames ideally (at least a couple of seconds)
max_average_speed = 15; % We're looking for the player which is a bit slower
% max_average_height is number of pixels the top player should generally be
% from the top
max_average_height = 300; % Pixels
x_size = framesize(2);
min_x = x_size / 4;
max_x = x_size * 3 / 4;

% This function will return the first instance of the above conditions
% being satisfied, and will assume this is the serving player being tracked
% Assumptions being made is that the top player is the one serving
filtered_player_cluster = filter_top_player_cluster(tracked_clusters,min_frames,max_average_speed,max_average_height, min_x, max_x);

% Assuming we found the correct player cluster under
% filtered_player_cluster, we now need to find the exact frame where the
% cluster is a maximum.

size_thresh = 1000;
top_value = get_top_y_values(filtered_player_cluster.Trajectory,size_thresh);

% plot_frame_and_point(top_value, vid);




% Now we need to find location of impact




min_frames = round(6 / 30 * frame_rate);
min_average_speed = 15; % pixels per frame
% hard_min_avg_speed = 15;
filtered_clusters = filter_short_clusters(tracked_clusters, min_frames, min_average_speed);

max_angle_change = 20;
hard_max_angle_change = 40;
min_ones = 1;

% max_angle_change = 999999;
filtered_angles = filter_angles(filtered_clusters,max_angle_change,hard_max_angle_change,min_ones);

intersection_value = compute_quadratic_regression(filtered_angles(1).Trajectory,filtered_angles(2).Trajectory);


% plot_trajectory(trajectory, vid,value)
% plot_frame_and_point(intersection_value, vid);

time_estimate = (intersection_value.Frame-top_value.Frame) / frame_rate;



k_Cd = 0.02; % Property of tennis ball



% vid = VideoReader('Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/TennisClipNoLoss.mp4');
% corners = corner_tracking(vid);

Frame_Number = round(intersection_value.Frame);

videoFrame = read(vid, Frame_Number+1);

corners = find_corners(videoFrame, {});



corners_world = [
    -5.485,  11.885; % Top Left
     5.485,  11.885; % Top Right
     5.485, -11.885; % Bottom Right
    -5.485, -11.885 % Bottom Left
];

distance_estimate = compute_distance_estimate(corners, corners_world, intersection_value, top_value);

speed_estimate = (exp(k_Cd*distance_estimate) - 1) / (k_Cd * time_estimate); % m/s

% Convert to mph
mph_final_speed = speed_estimate * 2.23694

% Convert to kph
kph_final_speed = speed_estimate * 3.6

top_pt = [top_value.X, top_value.Y];
projected_top_point = interpolate_y([corners{2,2}, corners{2,3}], [corners{3,2}, corners{3,3}], top_value.X);
intersection_pt = [intersection_value.X, intersection_value.Y];



radar_speed_mph = regexp(filename, '(\d+)(?=.mp4$)', 'match');
radar_speed_mph = str2double(radar_speed_mph{end});

unit = 'KPH';  % Default to KPH if MPH is not found
% Check if 'MPH' is in the filename
if contains(filename, 'MPH')
    unit = 'MPH';  % Set unit to MPH if found
end

if strcmp(unit, 'KPH')
    radar_speed_mph = radar_speed_mph * 0.621371;
end

plot_court_and_points(videoFrame,corners,top_pt,intersection_pt, projected_top_point, distance_estimate, time_estimate, mph_final_speed, radar_speed_mph)


% Save plot
[filepath, name, ~] = fileparts(filename);
outputFilename = fullfile(filepath, [name, '.png']);
saveas(gcf, outputFilename);



























% 
% 
% 
% 
% 
% 
% 
% 
% % plot_trajectory(filtered_clusters(1).Trajectory,vid)
% 
% % plot_trajectory(filtered_player_cluster.Trajectory,vid,'top')
% 
% 
% % Top_y_2D spatial coordinate (only estimating horizontal distance, Assume
% % z=0, and y = 11.885. Just use interpolation to figure out x-value.
% 
% 
% 
% 
% plot_corners(corners, vid,true,true)
% 
% top_y_estimate = 11.885; % meters
% top_value.corners = cell2mat(corners(top_value.Frame));
% % [top_x, top_y, top_z] = convert_2D_pts_to_3D(top_value.X, top_value.Y, top_y_estimate, top_value.corners, 'estimateAxis', 'y');
% % [top_x,top_y,top_z] = convert_2D_pts_to_3D(top_value.X,top_value.Y,top_z_estimate,top_value.corners); % Returns in units of meters
% 
% time = (intersection_value.Frame - top_value.Frame)/frame_rate;
% 
% top_value.corners = cell2mat(corners(top_value.Frame));
% pixelX = top_value.X;
% pixelY = top_value.Y;
% longSideEstimate = top_y_estimate;  % You want to lock Y=23.77
% 
% corners_world = [
%     -5.485,  11.885, 0;
%      5.485,  11.885, 0;
%      5.485, -11.885, 0;
%     -5.485, -11.885, 0
% ];
% 
% [X_3D, Y_3D, Z_3D, pos, orientation] = mapTennisPixelTo3D( ...
%     pixelX, pixelY, ...
%     top_value.corners, corners_world, ...
%     longSideEstimate, 'y');
% 
% 
% 
% bottom_z_estimate = 0; % meters
% intersection_value.corners = cell2mat(corners(round(intersection_value.Frame)));
% % [bottom_x,bottom_y,bottom_z] = convert_2D_pts_to_3D(intersection_value.X,intersection_value.Y,bottom_z_estimate,intersection_value.corners); % Returns in units of meters
% 
% 
% pixelX = intersection_value.X;
% pixelY = intersection_value.Y;
% 
% [X_3D_bot, Y_3D_bot, Z_3D_bot] = mapTennisPixelTo3D( ...
%     pixelX, pixelY, ...
%     intersection_value.corners, corners_world, ...
%     bottom_z_estimate, 'z');
% 
% 
% 
% 
% speed_estimates = parabolic_estimation_filtering(filtered_clusters, corners, frame_rate); % Returns m/s
% 
% speed_estimate_km_hr = speed_estimates * 3.6;
% 
% 
% 
% 
% 
% 
% 
% 
% plot_trajectory(filtered_clusters(1).Trajectory,vid)
% 
% plot_corners(corners, vid, true, true);
% 
% 
% 
% 
% fastest_per_frame = filter_by_frames_and_speed(filtered_clusters,min_frames,min_average_speed);
% 
% 
% % vid = VideoReader('Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/TennisRallyClip1.mp4');
% % plot_tracked_clusters(vid,filtered_clusters)
% 
% 
% fastest_per_frame_interp = interpolate_nan_positions(fastest_per_frame);
% 
% 
% compute_angle_change(fastest_per_frame_interp)
% 
% plot_fastest_cluster(vid, fastest_per_frame_interp)
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% % Smooth corner data:
% %%
% corners.smoothed_data = {};
% b=corners.data{1};
% corners.valid = {};
% thresh = 20;
% 
% new_b=b;
% valid = 1;
% corners.valid{1} = valid;
% corners.smoothed_data{1} = new_b;
% for i=2:length(corners.data)
%     if valid
%         a=new_b;
%     end
%     valid=1;
%     b=corners.data{i};
%     if height(a)==4 && height(b)==4
%         [new_b, valid] = check_valid_corner(thresh,a,b);
%     else
%         valid=0;
%     end
%     corners.valid{i} = valid;
%     corners.smoothed_data{i} = new_b;
% end
% 
% corners = interpolate_bad_data(corners);
% 
% 
% %% Functions:
% % function [new_b, valid] = check_valid_corner(thresh,a,b)
% %     thresh_sqrd = thresh^2;
% %     D = zeros(height(a),height(b));
% %     for i=1:height(a)
% %         for j=1:height(b)
% %             U = a(i,:);
% %             V = b(j,:);
% %             D(i,j)=(U(1)-V(1)).^2+(U(2)-V(2)).^2; % Squared distance between pts
% %         end
% %     end
% %     [min_D, idx] = min(D);
% %     norm_min_D = min_D./max(D);
% %     valid = all(norm_min_D < thresh_sqrd);
% %     if valid
% %         new_b = zeros(size(b));
% %         for i=1:length(idx)
% %             new_b(i,:) = b(idx(i),:);
% %         end
% %     else
% %         new_b=0;
% %     end
% % end
% 
% 
% % Close the video file
% 
% % 
% % figure; 
% % vid = VideoReader('Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/TennisRallyClip1.mp4');
% % for i=1:length(corners.data)
% %     imshow(readFrame(vid))
% %     hold on;
% %     currentCorners = corners.data{i};
% %     plot(currentCorners(:,1), currentCorners(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
% %     %plot(corners(:,1,i), corners(:,2,i), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
% %     % plot(x_list(i), y_list(i), 'ro', 'MarkerSize', sqrt(sizes_list(i)), 'LineWidth', 2);
% %     hold off;
% %     %imshow(mask_array(:,:,i));
% %     pause(0.1);
% % end
% % 
% % 
% % 
% 
% 
% 
% function videoFrame_Sharpened = edge_detect(videoFrame)
%     videoFrame = im2gray(videoFrame);    
% 
% 
%     blurAmount = 2;
%     kernelSize = 2 * ceil(2 * blurAmount) + 1;
%     gaussianFilter = fspecial('gaussian', [kernelSize kernelSize], blurAmount);
%     videoFrame_Blurred = imfilter(videoFrame, gaussianFilter, 'same');
%     videoFrame_Sharpened = imsharpen(videoFrame,Radius=2,Amount=1);
% 
%     lightEdgeThreshold = 0.3;
%     % BW = edge(videoFrame_Blurred);
%     BW = edge(videoFrame_Sharpened, 'Canny', lightEdgeThreshold/2);
% end
