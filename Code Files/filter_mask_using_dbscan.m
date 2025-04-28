function filteredMask = filter_mask_using_dbscan(resultMask, minClusterSize, minSize, epsilon)
    % Convert binary mask to a list of pixel coordinates
    [rows, cols] = find(resultMask);  % Get the nonzero pixel positions
    points = [cols, rows];  % Convert (row, col) to (x, y) format

    if isempty(points)
        filteredMask = false(size(resultMask)); % Return empty mask if no points
        return;
    end

    % Apply DBSCAN clustering
    minPts = minClusterSize; % Minimum points to form a cluster
    labels = dbscan(points, epsilon, minPts);

    % Identify unique clusters (excluding noise points labeled as -1)
    uniqueClusters = setdiff(unique(labels), -1);

    if isempty(uniqueClusters)
        filteredMask = false(size(resultMask)); % No valid clusters found
        return;
    end

    % Compute the centroid of each cluster
    clusterCentroids = zeros(length(uniqueClusters), 2);
    clusterSizes = zeros(length(uniqueClusters), 1);

    for i = 1:length(uniqueClusters)
        clusterPoints = points(labels == uniqueClusters(i), :);
        clusterCentroids(i, :) = mean(clusterPoints, 1); % Compute mean (centroid)
        clusterSizes(i) = size(clusterPoints, 1); % Get cluster size
    end

    % Filter clusters based on size
    validClusters = uniqueClusters(clusterSizes > minSize);
    validClusterCentroids = clusterCentroids(validClusters,:);
    if isempty(validClusters)
        filteredMask = false(size(resultMask)); % No clusters meeting size criteria
        return;
    end

    % Compute image center
    [height, width] = size(resultMask);
    centerPoint = [width / 2, height / 2];

    % Find the closest valid cluster to the center
    distances = vecnorm(validClusterCentroids - centerPoint, 2, 2);
    [~, closestIdx] = min(distances);
    bestCluster = validClusters(closestIdx);

    % Generate new mask with only the selected cluster
    filteredMask = false(size(resultMask));
    clusterPoints = points(labels == bestCluster, :);
    for j = 1:size(clusterPoints, 1)
        filteredMask(clusterPoints(j, 2), clusterPoints(j, 1)) = true;
    end
end
