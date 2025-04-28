function plot_corners_on_video(videoFile, corners, outputFile)
    % Function to overlay corner markers on a video and save the output
    
    % Open the input video
    vid = VideoReader(videoFile);
    
    % Create a VideoWriter object for the output
    if nargin > 2 && ~isempty(outputFile)
        outputVideo = VideoWriter(outputFile, 'MPEG-4');
        open(outputVideo);
    end
    
    % Initialize frame counter
    frameCounter = 1;

    % Loop through video frames
    while hasFrame(vid)
        videoFrame = readFrame(vid);
        
        % Plot the corners if valid data exists for the current frame
        if frameCounter <= length(corners.smoothed_data) && ...
           ~isempty(corners.smoothed_data{frameCounter})
            
            % Extract smoothed corner coordinates
            currentCorners = corners.smoothed_data{frameCounter};
            
            % Overlay circles on the frame
            figure('Visible', 'off');
            imshow(videoFrame);
            hold on;
            if istable(currentCorners)
                scatter(currentCorners.x, currentCorners.y, 100, 'r', 'filled');
            else
                scatter(currentCorners(:,1), currentCorners(:,2), 100, 'r', 'filled');
            end
            hold off;
            
            % Capture the annotated frame
            annotatedFrame = getframe(gca);
            close;
            
            % Write to the output video
            if exist('outputVideo', 'var')
                writeVideo(outputVideo, annotatedFrame.cdata);
            else
                imshow(annotatedFrame.cdata);
                pause(0.01); % To visualize in real-time
            end
        end
        
        frameCounter = frameCounter + 1;
    end
    
    % Close the output video if applicable
    if exist('outputVideo', 'var')
        close(outputVideo);
    end
end
