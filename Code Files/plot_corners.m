function plot_corners(corners, vid, plotCircles, plotLines)
% PLOT_CORNERS Interactive visualization of tennis court corners and lines on video frames.
% Inputs:
%   corners     - Structure containing smoothed_data with corner coordinates.
%   videoFile   - String path to the video file.
%   plotCircles - Boolean flag to toggle plotting circles around corners.
%   plotLines   - Boolean flag to toggle plotting court lines.

    % % Open video file
    % vid = VideoReader(videoFile);

    % Initialize frame counter
    frameCounter = 1;
    totalFrames = length(corners);

    % Define world and test points for plotting lines
    worldPoints = [ 
        -5.485, 11.885;  % Top-left corner (meters)
        5.485, 11.885;   % Top-right corner
        5.485, -11.885;  % Bottom-right corner
        -5.485, -11.885; % Bottom-left corner
    ];
    
    testWorldPoints = [
        % Line 1:
        0, 6.40;        % Intersection point at the "T"
        0, -6.40;       % Intersection point at the "T"
        % Line 2:
        -4.11, 6.4;     % Left service line intersection 
        4.11, 6.4;      % Right service line intersection 
        % Line 3:
        -4.11, -6.4;    % Bottom left service line intersection 
        4.11, -6.4;     % Bottom right service line intersection
        % Line 4:
        -4.11, -11.885;
        -4.11, 11.885;
        % Line 5:
        4.11, -11.885;
        4.11, 11.885
    ];

    % Loop until user quits
    while true
        % Ensure frameCounter stays within bounds
        frameCounter = max(1, min(frameCounter, totalFrames));

        % Read and display the current frame
        vid.CurrentTime = (frameCounter - 1) / vid.FrameRate;
        videoFrame = readFrame(vid);

        % Extract corner data for the current frame
        currentCorners = corners{frameCounter};

        % Plot frame and overlay corners/lines
        figure(1);
        imshow(videoFrame);
        hold on;

        % Display the frame counter
        title(sprintf('Frame %d of %d', frameCounter, totalFrames), 'FontSize', 14, 'Color', 'w');

        % Plot circles around the corners if enabled
        if plotCircles && ~isempty(currentCorners)
            if istable(currentCorners)
                scatter(currentCorners.x, currentCorners.y, 100, 'r', 'filled');
                imagePoints = [currentCorners.x, currentCorners.y];
            else
                scatter(currentCorners(:, 1), currentCorners(:, 2), 100, 'r', 'filled');
                imagePoints = currentCorners;
            end
        end

        % Plot court and service lines if enabled
        if plotLines && ~isempty(currentCorners)
            tform = fitgeotform2d(worldPoints, imagePoints, 'projective');
            testImagePoints = transformPointsForward(tform, testWorldPoints);

            % Plot service lines
            serviceLineIndices = [1, 2; 3, 4; 5, 6; 7, 8; 9, 10];
            for i = 1:size(serviceLineIndices, 1)
                plot(testImagePoints(serviceLineIndices(i, :), 1), testImagePoints(serviceLineIndices(i, :), 2), 'g-', 'LineWidth', 2);
            end

            % Plot court boundaries
            courtLineIndices = [1, 2; 2, 3; 3, 4; 4, 1];
            for i = 1:size(courtLineIndices, 1)
                plot(imagePoints(courtLineIndices(i, :), 1), imagePoints(courtLineIndices(i, :), 2), 'r-', 'LineWidth', 2);
            end
        end

        hold off;

        % Wait for user input
        waitforbuttonpress;
        key = get(gcf, 'CurrentCharacter');

        if key == 'q' % Quit
            close all;
            break;
        elseif key == char(29) % Next frame (Right Arrow)
            frameCounter = frameCounter + 1;
        elseif key == char(28) % Previous frame (Left Arrow)
            frameCounter = frameCounter - 1;
        end
    end
end