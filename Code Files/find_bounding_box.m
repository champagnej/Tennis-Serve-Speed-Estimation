function boundingBoxCorners = find_bounding_box(mask)
    % Find nonzero pixels (X, Y) coordinates from the binary mask
    [rows, cols] = find(mask);  
    points = [cols, rows];  % Convert to (x, y) format

    if isempty(points)
        error('No points found in the mask.');
    end

    % Compute Convex Hull
    k = convhull(points(:,1), points(:,2));

    % Extract Convex Hull coordinates
    hullPoints = points(k, :);  

    % Compute the Minimum Bounding Box (returns 4 corners)
    boundingBoxCorners = boundingBoxFromHull(hullPoints);

    % Display the results
    % figure; imshow(mask); hold on;
    % plot(points(:,1), points(:,2), 'g.');  % Plot all points
    % plot(hullPoints(:,1), hullPoints(:,2), 'r-', 'LineWidth', 2);  % Plot convex hull
    % plot([boundingBoxCorners(:,1); boundingBoxCorners(1,1)], ...
    %      [boundingBoxCorners(:,2); boundingBoxCorners(1,2)], 'b-', 'LineWidth', 2); % Draw bounding box
    % hold off;
end



function corners = boundingBoxFromHull(hullPoints)
    % boundingBoxFromHull selects four corners from the convex hull
    % based on coordinate sum/difference rules.
    %
    % Input:
    %   hullPoints - Nx2 matrix of convex hull points (assumed ordered)
    %
    % Outputs:
    %   corners    - 4x2 matrix containing the detected corner points
    %   valid      - Boolean flag; true if exactly 4 corners were found

    % Append the second point at the end to "wrap" the hull for angle calculation
    hullPoints = [hullPoints; hullPoints(2,:)];

    % Compute the required values for each point
    sum_values = hullPoints(:,1) + hullPoints(:,2);  % x + y
    diff_values = hullPoints(:,1) - hullPoints(:,2); % x - y

    % Find the four extreme points based on sum and difference
    [~, idx_top_left] = min(sum_values);  % Min sum -> Top Left
    [~, idx_bottom_right] = max(sum_values);    % Max sum -> Bottom Right
    [~, idx_bottom_left] = min(diff_values);    % Min difference -> Bottom Left
    [~, idx_top_right] = max(diff_values);% Max difference -> Top Right

    % Store the detected corners
    corners = {
        'Corner',   'X',    'Y';  % Column headers
        'Top Left', hullPoints(idx_top_left, 1), hullPoints(idx_top_left, 2);
        'Top Right', hullPoints(idx_top_right, 1), hullPoints(idx_top_right, 2);
        'Bottom Right', hullPoints(idx_bottom_right, 1), hullPoints(idx_bottom_right, 2);
        'Bottom Left', hullPoints(idx_bottom_left, 1), hullPoints(idx_bottom_left, 2)
    };


end
