function plot_trajectory(trajectory, vid,value)
    % Input validation
    if ~isstruct(trajectory) || isempty(trajectory)
        error('Trajectory must be a non-empty struct array');
    end
    
    % Read video
    if ischar(vid) || isstring(vid)
        vid = VideoReader(vid);
    elseif ~isa(vid, 'VideoReader')
        error('vid must be a VideoReader object or a valid video filename');
    end

    % Extract trajectory frames
    frames = [trajectory.Frame];

    if ~exist('value', 'var')
        value = 'mean';  % Set to empty string if the variable doesn't exist
    end
    if strcmp(value, 'top')
        X = [trajectory.Top_X];
        Y = [trajectory.Top_Y];
    else
        X = [trajectory.X];
        Y = [trajectory.Y];
    end
    % Initialize starting frame
    currentFrameIndex = 1; 
    maxFrameIndex = length(frames);

    % Create figure
    fig = figure('Name', 'Trajectory Viewer', 'KeyPressFcn', @keyPressCallback);
    
    % Main video loop
    keepRunning = true;
    while ishandle(fig) && keepRunning
        % Get current frame
        currentFrameNum = frames(currentFrameIndex);
        vid.CurrentTime = (currentFrameNum - 1) / vid.FrameRate;
        frame = readFrame(vid);

        % Display frame
        imshow(frame, 'Border', 'tight'); hold on;

        % Plot trajectory up to the current frame
        plot(X(1:currentFrameIndex), Y(1:currentFrameIndex), 'ro-', 'LineWidth', 2);

        % Pause for keypress
        uiwait(fig);
    end

    % Keypress callback function
    function keyPressCallback(~, event)
        switch event.Key
            case 'rightarrow'
                if currentFrameIndex < maxFrameIndex
                    currentFrameIndex = currentFrameIndex + 1;
                end
            case 'leftarrow'
                if currentFrameIndex > 1
                    currentFrameIndex = currentFrameIndex - 1;
                end
            case 'q' % Exit when 'q' is pressed
                keepRunning = false;
                if ishandle(fig) % Ensure figure still exists before closing
                    close(fig);
                end
        end
        % Resume only if figure exists
        if ishandle(fig)
            uiresume(fig);
        end
    end
end
