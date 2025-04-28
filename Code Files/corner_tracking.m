function corners_final = corner_tracking(vid)
% CORNER_TRACKING Detects and processes the corners of a tennis court in a video.
% Input:
%   vid - VideoReader object for the input video
% Output:
%   corners - Structure containing corner data and smoothed results

    % Initialization
    frameCounter = 0;
    max_Frames = 10000;

    prevmask = 0;
    corners.data = {};
    
    videoFrame = readFrame(vid);
    thresh = 2000;

    % Process video frames
    while hasFrame(vid) && frameCounter <= max_Frames

        prevFrame = videoFrame;
        videoFrame = readFrame(vid);

        if isempty(corners.data)
            [corners.data{1}, corner_details] = find_corners(videoFrame, {});
        else
            [corners.data{end+1}, corner_details] = find_corners(videoFrame, corner_details);
        end

        frameCounter = frameCounter + 1;
    end

    % Smooth corner data
    corners.smoothed_data = {};
    b = corners.data{1};
    corners.valid = {};
    thresh = 20;

    new_b = b;
    valid = 1;
    corners.valid{1} = valid;
    corners.smoothed_data{1} = new_b;

    for i = 2:length(corners.data)
        if valid
            a = new_b;
        end
        valid = 1;
        b = corners.data{i};

        if height(a) == 4 && height(b) == 4
            [new_b, valid] = check_valid_corner(thresh, a, b);
        else
            valid = 0;
        end

        corners.valid{i} = valid;
        corners.smoothed_data{i} = new_b;
    end

    % Interpolate bad data
    corners = interpolate_bad_data(corners);
    corners_final = corners.smoothed_data;
end

































































% % close all
% % clear all
% 
%     % hsvFrame = rgb2hsv(videoFrame);
%     % 
%     % hueMin = 0.45;  
%     % hueMax = 0.55;  
%     % satMin = 0.4;   
%     % valMin = 0.4;   
% 
% 
% % vid = VideoReader('Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/TennisClip2.mp4');
% 
% vid = VideoReader('Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/TennisRallyClip1_no_duplicates.avi');
% 
% myVideo = VideoWriter('myFile.avi');
% open(myVideo)
% 
% frameCounter = 0;
% max_Frames = 10000;
% 
% % while frameCounter <= 12
% %     videoFrame = readFrame(vid);
% %     frameCounter=frameCounter+1;
% % end
% 
% prevmask = 0;
% mask_array = 0;
% videoFrame = readFrame(vid);
% 
% % xpos = 664;
% % ypos = 37;
% % size = 25;
% 
% 
% thresh = 2000;
% 
% distances   = [];
% x_list      = [];
% y_list      = [];
% sizes_list  = [];
% frame_count_list = [];
% 
% % corners     = 0;
% corners.data = {};
% 
% 
% ball_xy_size = 0;
% 
% % for i=1:110
% %     videoFrame=readFrame(vid);
% % end
% 
% 
% while hasFrame(vid) && frameCounter <= max_Frames
% 
%     prevFrame = videoFrame;
%     videoFrame = readFrame(vid);
% 
%     if isempty(corners.data)
%         [corners.data{1}, corner_details] = find_corners(videoFrame, {});
%     else
%         [corners.data{end+1}, corner_details] = find_corners(videoFrame, corner_details);
%     end
%     disp(frameCounter)
%     % disp(corner_details.valid)
%     % if corners == 0
%     %     corners = find_corners(videoFrame);
%     % else
%     %     corners(:,:,end+1) = find_corners(videoFrame);
%     % end
% 
% 
%     % if isequal(ball_xy_size,0)
%     %     % ball_xy_size = find_ball(videoFrame, prevFrame, thresh, 0, corners(:,:,end));
%     %     [ball_xy_size, prevmask] = find_ball2(videoFrame, prevFrame, thresh, 0, 0);
%     % else
%     %     % ball_xy_size(:,end+1) = find_ball(videoFrame, prevFrame, thresh, ball_xy_size, corners(:,:,end));
%     %     [ball_xy_size(:,end+1), prevmask] = find_ball2(videoFrame, prevFrame, thresh, ball_xy_size,prevmask);
%     % 
%     % end
% 
%     frameCounter = frameCounter + 1;
% end
% close(myVideo);
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
% vid = 'Tennis_Ball_Tracking/Tennis_Ball_Project/Tennis_Rally_Clips/TennisRallyClip1_no_duplicates.avi';
% output = 'Test_outputs/corner_test_1.avi';
% plot_corners_on_video(vid, corners, output);
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
