function distance_estimate = compute_distance_estimate(corners, corners_world, intersection_value, top_value)
    % Compute the homography matrix
    H = compute_homography(corners, corners_world);

    disp('Homography matrix (H.T):');
    disp(H.T);

    top_pt = interpolate_y([corners{2,2}, corners{2,3}], [corners{3,2}, corners{3,3}], top_value.X);
    intersection_pt = [intersection_value.X, intersection_value.Y];

    % Transform intersection_value to real-world coordinates
    real_world_intersection = map_to_real_world(H, intersection_pt);
    real_world_top_pt = map_to_real_world(H, top_pt);

        

    % Compute distance from top to real world position (assume z=0 for both)

    distance_estimate = norm(real_world_top_pt(1:2) - real_world_intersection(1:2));
    
end


function H = compute_homography(corners, real_points)
    % Extract corner pixel coordinates from the corners cell array
    img_points = [corners{2,2}, corners{2,3};  % Top Left
                  corners{3,2}, corners{3,3};  % Top Right
                  corners{4,2}, corners{4,3};  % Bottom Right
                  corners{5,2}, corners{5,3}]; % Bottom Left

    % Compute homography using fitgeotrans
    H = fitgeotrans(img_points, real_points, 'projective');  % Projective transformation
end


function real_world_position = map_to_real_world(H, pixel_coord)
    % Convert pixel coordinate to a row vector [x, y, 1]
    pixel_coord_row = [pixel_coord(1), pixel_coord(2), 1];
    
    % Apply homography transformation using row vector multiplication
    mapped_coord = pixel_coord_row * H.T;
    
    % Normalize by the homogeneous coordinate
    mapped_coord = mapped_coord / mapped_coord(3);
    
    % Assuming a flat court, set Z = 0 (2D to 3D conversion)
    real_world_position = [mapped_coord(1), mapped_coord(2), 0];  
end

