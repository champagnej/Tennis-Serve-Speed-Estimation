function [X_3D, Y_3D, Z_3D, cameraPosition, cameraOrientation] = mapTennisPixelTo3D( ...
    pixelX, pixelY, ...
    corners_pixel, corners_world, ...
    estimateValue, axisToEstimate)
% mapTennisPixelTo3D  Converts a 2D pixel coordinate to 3D world coordinates.
%                     Also estimates the camera's position and orientation.

    % Validate Inputs
    if size(corners_pixel,2) ~= 2 || size(corners_world,2) ~= 3
        error('corners_pixel must be Nx2 and corners_world must be Nx3 (X,Y,Z).')
    end
    if ~ismember(axisToEstimate, {'y', 'z'})
        error('axisToEstimate must be ''y'' (lock Y) or ''z'' (lock Z).');
    end

    
    
    
    % Estimate Camera Projection Matrix (P)
    % Solve 3x4 camera projection matrix P using Direct Linear Transformation (DLT)
    P = computeProjectionMatrix(corners_pixel, corners_world);

    % Extract Rotation (R) and Translation (T) from P
    [R, T] = extractCameraPose(P);
    
    % Compute the camera's position in world coordinates
    cameraPosition = -R' * T;
    cameraOrientation = R;

    
    % Compute Homography for 2D Mapping
    % Use a homography transform to map pixels to 2D real-world coordinates on the court
    H = fitgeotform2d(corners_pixel, corners_world(:,1:2), 'projective');

    % Convert input pixel coordinate to real-world X, Y
    [X_2D, Y_2D] = transformPointsForward(H, pixelX, pixelY);

    
    
    
    % Assign the Estimated Z or Y Value
    switch axisToEstimate
        case 'z'  % Assume we know the height (Z)
            X_3D = X_2D;
            Y_3D = Y_2D;
            Z_3D = estimateValue;

        case 'y'  % Assume we know the Y position (court length)
            X_3D = X_2D;
            Z_3D = Y_2D;
            Y_3D = estimateValue;
    end
end


function P = computeProjectionMatrix(imagePoints, worldPoints)
    % Solve for the 3x4 projection matrix P using the Direct Linear Transformation (DLT) method.
    % Requires at least 4 corresponding 2D-3D point pairs.
    
    num_points = size(imagePoints, 1);
    A = zeros(2 * num_points, 12);

    for i = 1:num_points
        X = worldPoints(i, 1);
        Y = worldPoints(i, 2);
        Z = worldPoints(i, 3);
        x = imagePoints(i, 1);
        y = imagePoints(i, 2);

        A(2*i-1, :) = [-X, -Y, -Z, -1,  0,  0,  0,  0, x*X, x*Y, x*Z, x];
        A(2*i, :)   = [ 0,  0,  0,  0, -X, -Y, -Z, -1, y*X, y*Y, y*Z, y];
    end

    % Solve for P using SVD (least squares)
    [~, ~, V] = svd(A);
    P = reshape(V(:, end), 4, 3)'; % Reshape last column into a 3x4 matrix
end


function [R, T] = extractCameraPose(P)
    % Extract the camera's rotation matrix R and translation vector T from projection matrix P.
    
    % The first three columns of P give us [R | t]
    M = P(:, 1:3);  
    [U, ~, V] = svd(M); % Ensure R is orthonormal using SVD
    R = U * V';  % Ensure it's a valid rotation matrix
    T = P(:, 4);
end




