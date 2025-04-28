function plot_court_and_points(frame, corners, top_pt, intersection_pt, projected_top_point, distance_estimate, time_estimate, mph_final_speed, radar_speed_mph)
    % plot_court_and_points overlays the court corners (pixel coordinates),
    % the top point, and the intersection point on the input image.
    %
    % Inputs:
    %   frame          - The image (or video frame) to plot on.
    %   corners        - A cell array containing corner info.
    %                    Expected rows (with headers in row 1):
    %                    Row 2: {'Top Left', X, Y}
    %                    Row 3: {'Top Right', X, Y}
    %                    Row 4: {'Bottom Right', X, Y}
    %                    Row 5: {'Bottom Left', X, Y}
    %   top_pt         - [x, y] pixel coordinate for the computed top point.
    %   intersection_pt- [x, y] pixel coordinate for the computed intersection.
    
    figure;
    imshow(frame);
    hold on;
    
    % Extract the corner points from the cell array.
    % (Assuming the first row is a header; actual points start at row 2.)
    tl = [corners{2,2}, corners{2,3}];  % Top Left
    tr = [corners{3,2}, corners{3,3}];  % Top Right
    br = [corners{4,2}, corners{4,3}];  % Bottom Right
    bl = [corners{5,2}, corners{5,3}];  % Bottom Left
    
    % Draw the boundary of the court by connecting the corners.
    xCourt = [tl(1), tr(1), br(1), bl(1), tl(1)];
    yCourt = [tl(2), tr(2), br(2), bl(2), tl(2)];
    plot(xCourt, yCourt, 'r-', 'LineWidth', 2);
    
    % Plot and label each corner.
    for i = 2:size(corners,1)
        label = corners{i,1};
        x_pt = corners{i,2};
        y_pt = corners{i,3};
        plot(x_pt, y_pt, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
        text(x_pt + 5, y_pt, label, 'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');
    end

    % Plot and label the top point.
    plot(top_pt(1), top_pt(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    text(top_pt(1) + 5, top_pt(2), 'Top Point', 'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');

    % Plot and label the projected top point.
    plot(projected_top_point(1), projected_top_point(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    text(projected_top_point(1) + 5, projected_top_point(2), 'Projected Top Point', 'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');

    % Plot and label the intersection point.
    plot(intersection_pt(1), intersection_pt(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    text(intersection_pt(1) + 5, intersection_pt(2), 'Intersection', 'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');
    
    plot([projected_top_point(1), intersection_pt(1)], ...
     [projected_top_point(2), intersection_pt(2)], ...
     'b-', 'LineWidth', 2); % 'b-' for a blue line

    mid_x = (projected_top_point(1) + intersection_pt(1)) / 2;
    mid_y = (projected_top_point(2) + intersection_pt(2)) / 2;
    
    text(mid_x, mid_y, sprintf('Horizontal Displacement'), ...
        'Color', 'cyan', 'FontSize', 12, 'FontWeight', 'bold');


    hold off;

    xlabel(sprintf(['Distance Estimate: %.2f m | Time Estimate: %.2f s\n',...
        'Final Speed: %.2f mph | Radar Speed: %.2f mph'],...
        distance_estimate, time_estimate, mph_final_speed, radar_speed_mph), ...
    'FontSize', 12, 'FontWeight', 'bold');

set(gcf, 'Units', 'inches', 'Position', [1, 1, 10, 6]); % Adjust figure size as needed
set(gca, 'Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8]);  % Adjust the axis position

    % annotation('textbox', [0.3, 0.01, 0.4, 0.05], ...
    % 'String', sprintf('Distance Estimate: %.2f m | Time Estimate: %.2f s', distance_estimate, time_estimate), ...
    % 'FontSize', 12, ...
    % 'FontWeight', 'bold', ...
    % 'EdgeColor', 'none', ...
    % 'HorizontalAlignment', 'center', ...
    % 'Color', 'white', ...
    % 'BackgroundColor', 'black');


end
