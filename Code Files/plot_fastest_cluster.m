function plot_fastest_cluster(vid, fastest_per_frame)

    % Handle the case when fastest_per_frame is 0
    if fastest_per_frame == 0
        fastest_per_frame = []; % Set it as an empty array to skip plotting clusters
    end

    % Determine maxFrame only if fastest_per_frame is not empty
    if ~isempty(fastest_per_frame)
        maxFrame = max(fastest_per_frame(:,1), [], 'omitnan'); % Use omitnan for safety
    else
        maxFrame = inf; % If no cluster data, assume infinite playback
    end

    % Set the CurrentTime property of the VideoReader object to the start
    vid.CurrentTime = 0; 

    % Initialize figure
    hFig = figure;
    set(hFig, 'Position', [100, 100, vid.Width, vid.Height]);
    set(hFig, 'KeyPressFcn', @keyPressCallback);

    % Initialize frame index
    currentFrameIdx = 1;

    % Preload all frames for navigation
    frames = {};
    while hasFrame(vid)
        frames{end+1} = readFrame(vid);
    end

    % Display the initial frame
    updateFrame();

    % Callback for key press
    function keyPressCallback(~, event)
        if strcmp(event.Key, 'leftarrow')
            % Go to the previous frame
            currentFrameIdx = max(1, currentFrameIdx - 1);
            updateFrame();
        elseif strcmp(event.Key, 'rightarrow')
            % Go to the next frame
            currentFrameIdx = min(length(frames), currentFrameIdx + 1);
            updateFrame();
        end
    end

    % Function to update the frame display
    function updateFrame()
        frame = frames{currentFrameIdx};

        % Display the frame
        imshow(frame);
        hold on;

        if ~isempty(fastest_per_frame) && currentFrameIdx <= size(fastest_per_frame, 1)
            % Extract data for this frame
            frame_data = fastest_per_frame(currentFrameIdx, :);
            % frame_data = [Frame, X, Y, ClusterID]

            if ~isnan(frame_data(2)) && ~isnan(frame_data(3))
                % Plot the fastest cluster
                x = frame_data(2);
                y = frame_data(3);
                clusterID = frame_data(4);

                % Define marker properties
                markerSize = 10; % Adjust as needed
                markerColor = 'r'; % Red
                plot(x, y, 'o', 'MarkerSize', markerSize, 'MarkerEdgeColor', markerColor, 'LineWidth', 2);

                % Display Cluster ID as text
                text(x + 5, y + 5, num2str(clusterID), 'Color', 'yellow', 'FontSize', 10, 'FontWeight', 'bold');
            end
        end

        hold off;
        title(sprintf('Frame %d', currentFrameIdx));
    end
end







% function plot_fastest_cluster(vid, fastest_per_frame)
% 
%     % if isempty(fastest_per_frame)
%     %     error('fastest_per_frame is empty. Nothing to plot.');
%     % end
% 
%     if fastest_per_frame == 0
%         fastest_per_frame = [];
%     end
%     maxFrame = max(fastest_per_frame(:,1));
% 
%     % Set the CurrentTime property of the VideoReader object to the start
%     vid.CurrentTime = 0; 
% 
%     % Initialize figure
%     hFig = figure;
%     set(hFig, 'Position', [100, 100, vid.Width, vid.Height]);
% 
%     % Initialize previousFrame for duplicate detection
%     previousFrame = [];
% 
%     % Initialize frame counter
%     currentFrameIdx = 1;
% 
%     % Read and plot frames
%     while hasFrame(vid)
%         frame = readFrame(vid);
% 
%         % Check for duplicate frames
%         if ~isempty(previousFrame)
%             frameDifference = imabsdiff(frame, previousFrame);
%             % Convert to grayscale for comparison
%             frameDifferenceGray = rgb2gray(frameDifference);
%             threshold = 20; % Adjust threshold as needed
%             diffMask = frameDifferenceGray > threshold;
%             numDiffPixels = sum(diffMask(:));
% 
%             if numDiffPixels < 20
%                 % Duplicate frame; skip plotting this frame
%                 previousFrame = frame;
%                 % currentFrameIdx = currentFrameIdx + 1; 
%                 continue;
%             end
%         end
% 
%         % Update previousFrame
%         previousFrame = frame;
% 
%         % Check if currentFrameIdx is within fastest_per_frame
%         if currentFrameIdx > size(fastest_per_frame, 1)
%             % No data for this frame, just display
%             imshow(frame);
%             title(sprintf('Frame %d', currentFrameIdx));
%         else
%             % Extract data for this frame
%             frame_data = fastest_per_frame(currentFrameIdx, :);
%             % frame_data = [Frame, X, Y, ClusterID]
% 
%             % Display the frame
%             imshow(frame);
%             hold on;
% 
%             if ~isnan(frame_data(2)) && ~isnan(frame_data(3))
%                 % Plot the fastest cluster
%                 x = frame_data(2);
%                 y = frame_data(3);
%                 clusterID = frame_data(4);
% 
%                 % Define marker properties
%                 markerSize = 10; % Adjust as needed
%                 markerColor = 'r'; % Red
%                 plot(x, y, 'o', 'MarkerSize', markerSize, 'MarkerEdgeColor', markerColor, 'LineWidth', 2);
% 
%                 % Display Cluster ID as text
%                 text(x + 5, y + 5, num2str(clusterID), 'Color', 'yellow', 'FontSize', 10, 'FontWeight', 'bold');
%             end
% 
%             hold off;
%             title(sprintf('Frame %d', currentFrameIdx));
%         end
% 
%         drawnow;
% 
%         % Increment frame counter
%         currentFrameIdx = currentFrameIdx + 1;
% 
%         % Optional: Allow user to close the figure to stop playback
%         if ~ishandle(hFig)
%             break;
%         end
%     end
% 
%     % Close the figure after processing
%     if ishandle(hFig)
%         close(hFig);
%     end
% end
