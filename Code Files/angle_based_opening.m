function combinedMask = angle_based_opening(binaryImage, angleStep, lineLength, edgeThreshold)
    % Function to perform binary opening for different angles and remove edge lines
    % Inputs:
    %   binaryImage - Input binary image
    %   angleStep - Step size for angle variation
    %   lineLength - Length of structuring element
    %   edgeThreshold - Distance from edge to remove detected lines
    % Output:
    %   combinedMask - Combined binary mask after applying all angles

    % Initialize empty mask
    combinedMask = false(size(binaryImage));

    % Define angles to iterate over (0 to 180 degrees)
    angles = 0:angleStep:180;
    
    [height, width] = size(binaryImage); % Get image dimensions

    % Loop over each angle
    for theta = angles
        % Create line structuring element for given angle
        se = strel('line', lineLength, theta);
        
        
        % Perform morphological opening (erosion followed by dilation)
        openedMask = imopen(binaryImage, se);
        % Must have a way of recording all the lines start/end point
        % In other words, the result image should be able to be
        % reconstructed using only start and end lines saved to a list


        % Remove lines that touch the edges within the threshold
        openedMask = remove_edge_lines(openedMask, height, width, edgeThreshold);

        % Combine result using logical OR
        combinedMask = combinedMask | openedMask;
    end
end

function filteredMask = remove_edge_lines(binaryMask, height, width, edgeThreshold)
    % Removes lines that are too close to the edges
    % Inputs:
    %   binaryMask - Binary image mask
    %   height, width - Image dimensions
    %   edgeThreshold - Distance threshold for removal
    % Output:
    %   filteredMask - Mask with edge-adjacent lines removed

    % Identify connected components (lines)
    CC = bwconncomp(binaryMask);

    % Initialize output mask
    filteredMask = binaryMask;

    for i = 1:CC.NumObjects
        % Get pixel indices of current component
        [rows, cols] = ind2sub(size(binaryMask), CC.PixelIdxList{i});
        
        % Check if any part of the component is too close to the edge
        if any(rows < edgeThreshold | rows > (height - edgeThreshold) | ...
               cols < edgeThreshold | cols > (width - edgeThreshold))
            % Remove the entire connected component
            filteredMask(CC.PixelIdxList{i}) = 0;
        end
    end
end








% function combinedMask = angle_based_opening(binaryImage, angleStep, lineLength, edgeThreshold)
%     % Function to perform binary opening for different angles
%     % Inputs:
%     %   binaryImage - Input binary image
%     %   angleStep - Step size for angle variation
%     %   lineLength - Length of structuring element
%     % Output:
%     %   combinedMask - Combined binary mask after applying all angles
% 
%     % Initialize empty mask
%     combinedMask = false(size(binaryImage));
% 
%     % Define angles to iterate over (0 to 180 degrees)
%     angles = 0:angleStep:180;
% 
%     % Loop over each angle
%     for theta = angles
%         % Create line structuring element for given angle
%         se = strel('line', lineLength, theta);
% 
%         % Perform morphological opening (erosion followed by dilation)
%         openedMask = imopen(binaryImage, se);
% 
%         % Combine result using logical OR
%         combinedMask = combinedMask | openedMask;
%     end
% end
