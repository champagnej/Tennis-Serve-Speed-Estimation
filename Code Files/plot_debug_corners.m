function plot_debug_corners(frame, hullPoints, filtered_points)
    % plot_debug_corners overlays the convex hull and detected corners
    % onto the reference frame for debugging.
    %
    % Inputs:
    %   frame          - The image (or video frame) to plot on.
    %   hullPoints     - Nx2 array of convex hull points.
    %   filtered_points - Mx2 array of filtered corner points.
    
    figure;
    imshow(frame); hold on;
    
    % Plot the convex hull as a red polygon
    plot(hullPoints(:,1), hullPoints(:,2), 'r-', 'LineWidth', 2);
    
    % Scatter plot for all convex hull points
    scatter(hullPoints(:,1), hullPoints(:,2), 30, 'red', 'filled', 'MarkerEdgeColor', 'black');
    
    % Scatter plot for detected corners (filtered points)
    scatter(filtered_points(:,1), filtered_points(:,2), 50, 'g', 'filled', 'MarkerEdgeColor', 'black');
    
    % Label the points
    for i = 1:size(hullPoints,1)
        text(hullPoints(i,1) + 5, hullPoints(i,2), sprintf('H%d', i), 'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');
    end
    
    for i = 1:size(filtered_points,1)
        text(filtered_points(i,1) + 5, filtered_points(i,2), sprintf('C%d', i), 'Color', 'cyan', 'FontSize', 12, 'FontWeight', 'bold');
    end
    
    title('Convex Hull and Detected Corners Debug Plot');
    hold off;
end
