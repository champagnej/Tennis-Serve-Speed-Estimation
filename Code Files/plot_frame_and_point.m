function plot_frame_and_point(result, vid)
    % This function plots the specific video frame with the Top_X and Top_Y point
    % overlaid, along with the frame number and coordinate values.
    %
    % Input:
    %   result - A struct containing the Frame, Top_Y, and Top_X values
    %   vid - VideoReader object for the video file

    % Check if the result is empty
    if isempty(result.Frame)
        warning('No valid data to plot.');
        return;
    end

    % Read the specific video frame
    vid.CurrentTime = (round(result.Frame) - 1) / vid.FrameRate;
    frame = readFrame(vid);

    % Display the frame
    figure;
    imshow(frame);
    hold on;

    % Overlay the point
    plot(result.X, result.Y, 'ro', 'MarkerSize', 10, 'LineWidth', 2);

    % Annotate with frame number, Top_X, and Top_Y
    text(result.X + 10, result.Y + 10, ...
        sprintf('Frame: %d\nX: %.1f\nY: %.1f', result.Frame, result.X, result.Y), ...
        'FontSize', 12, 'Color', 'yellow', 'FontWeight', 'bold');

    % Annotate the frame number
    title(sprintf('Frame %d', result.Frame), 'FontSize', 16, 'Color', 'white');

    % Add a circle around the point
    viscircles([result.X, result.Y], 2, 'EdgeColor', 'red');

    hold off;
end
