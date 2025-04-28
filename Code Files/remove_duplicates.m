function remove_duplicates(inputVideoPath, outputVideoPath, thresh)
    % Removes duplicate frames from a video based on a difference threshold.
    %
    % inputVideoPath: Path to the input video file.
    % outputVideoPath: Path to the output video file (without duplicates).
    % thresh: Threshold for frame difference to consider a frame as duplicate.

    % Read the input video
    vid = VideoReader(inputVideoPath);

    % Ensure output extension is .avi since VideoWriter appends .avi
    [outputPath, outputName, ~] = fileparts(outputVideoPath);
    outputVideoPath = fullfile(outputPath, strcat(outputName, '.avi'));

    % Create a VideoWriter object for the output
    outputVideo = VideoWriter(outputVideoPath);
    open(outputVideo);

    % Initialize frame processing
    prevFrame = [];  % Previous frame for comparison
    frameCounter = 0; % Counter for frames written

    % Process the video frame by frame
    while hasFrame(vid)
        % Read the next frame
        currentFrame = readFrame(vid);
        % Convert the frame to grayscale for comparison
        currentFrameGray = rgb2gray(currentFrame);

        if isempty(prevFrame)
            % Write the first frame to the output
            writeVideo(outputVideo, currentFrame);
            prevFrame = currentFrameGray;
            frameCounter = frameCounter + 1;
            continue;
        end

        % Calculate the absolute difference between frames
        frameDiff = sum(sum(imabsdiff(prevFrame, currentFrameGray) > 20));

        % Check if the difference exceeds the threshold
        if frameDiff > thresh
            % Write the current frame to the output
            writeVideo(outputVideo, currentFrame);
            prevFrame = currentFrameGray; % Update previous frame
            frameCounter = frameCounter + 1;
        end
    end

    % Close the output video
    close(outputVideo);

    fprintf('Duplicate frame removal complete. %d frames written to %s\n', frameCounter, outputVideoPath);
end
