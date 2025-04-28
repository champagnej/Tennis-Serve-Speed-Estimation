function plot_tracked_clusters(vid, tracked_clusters)
    % Initialize figure
    hFig = figure;
    set(hFig, 'Position', [100, 100, vid.Width, vid.Height]);

    % Initialize previousFrame for duplicate detection
    previousFrame = [];

    % Initialize frame indices
    videoFrameIdx = 1;       % Index for video frames
    trackingFrameIdx = 1;    % Index for tracking data frames

    % Loop until all video frames are processed or figure is closed
    while hasFrame(vid) && ishandle(hFig)
        % Read the current frame
        currentFrame = readFrame(vid);

        % Check for duplicate frames
        if ~isempty(previousFrame)
            frameDifference = imabsdiff(currentFrame, previousFrame);
            % Convert to grayscale for comparison
            frameDifferenceGray = rgb2gray(frameDifference);
            threshold = 20; % Adjust threshold as needed
            diffMask = frameDifferenceGray > threshold;
            numDiffPixels = sum(diffMask(:));

            if numDiffPixels < 20
                % Duplicate frame; skip plotting but do not increment trackingFrameIdx
                % fprintf('Video Frame %d is a duplicate. Skipping plotting.\n', videoFrameIdx);
                previousFrame = currentFrame;
                videoFrameIdx = videoFrameIdx + 1;
                continue;
            end
        end

        % Update previousFrame
        previousFrame = currentFrame;

        % Display the frame
        imshow(currentFrame);
        hold on;

        % Get the image dimensions
        image_height = size(currentFrame, 1);
        image_width = size(currentFrame, 2);

        % Check if there is tracking data for the current trackingFrameIdx
        if trackingFrameIdx <= length(tracked_clusters)
            % Loop through each tracked cluster
            for i = 1:length(tracked_clusters)
                cluster = tracked_clusters(i);
                % Find the index in Trajectory where Frame_Number == trackingFrameIdx
                idx = find(cluster.Trajectory(:,1) == trackingFrameIdx);
                if ~isempty(idx)
                    % Get cluster position and size
                    x = cluster.Trajectory(idx, 2);
                    y = cluster.Trajectory(idx, 3);
                    size_val = cluster.Trajectory(idx, 4);

                    % Debugging: Print cluster information
                    fprintf('Video Frame %d, Cluster ID %d: x = %.2f, y = %.2f, size = %.2f\n', ...
                            trackingFrameIdx, cluster.ID, x, y, size_val);

                    % Scale size by square root
                    size_sqrt = sqrt(size_val);

                    % Ensure cluster coordinates are within image bounds
                    if x < 1 || x > image_width || y < 1 || y > image_height
                        fprintf('Cluster ID %d has out-of-bounds coordinates: x = %.2f, y = %.2f\n', ...
                                cluster.ID, x, y);
                        continue; % Skip plotting this cluster
                    end

                    % Plot the cluster using scatter for better size control
                    % Adjust scaling factor as needed
                    markerSize = size_sqrt * 0.5; % Adjust scaling factor
                    scatter(x, y, markerSize, 'ro', 'LineWidth', 1.5);

                    % Optionally, display the cluster ID
                    text(x + 5, y + 5, num2str(cluster.ID), 'Color', 'yellow', 'FontSize', 10);
                end
            end
        end

        hold off;
        drawnow;

        % Increment frame indices
        videoFrameIdx = videoFrameIdx + 1;
        trackingFrameIdx = trackingFrameIdx + 1;
    end

    % Close the figure after processing
    if ishandle(hFig)
        close(hFig);
    end
end
