function tennis_ball_main(filename, frame_rate)


vid = VideoReader(filename);

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
