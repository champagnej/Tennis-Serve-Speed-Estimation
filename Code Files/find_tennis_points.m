
function valid = find_tennis_points(image_points, plotting, videoFrame, compute_accuracy)

    % imagePoints = [
    %     419.033, 162;  % Top-left corner
    %     839.288, 162;  % Top-right corner
    %     178.63, 547;   % Bottom-left corner
    %     1088.65, 547   % Bottom-right corner
    % ];

    worldPoints = [ 
    -5.485, 11.885;  % Top-left corner (meters)
    5.485, 11.885;   % Top-right corner
    5.485, -11.885   % Bottom-right corner
    -5.485, -11.885; % Bottom-left corner


];
    testWorldPoints = [
    % Line 1:
    0, 6.40;        % Intersection point at the "T"
    0, -6.40;       % Intersection point at the "T"
    % Line 2:
    -4.11, 6.4;     % Left service line intersection 
    4.11, 6.4;      % Right service line intersection 
    % Line 3:
    -4.11, -6.4;    % Bottom left service line intersection 
    4.11, -6.4;      % Bottom right service line intersection
    % Line 4:
    -4.11, -11.885;
    -4.11, 11.885;
    % Line 5:
    4.11, -11.885;
    4.11, 11.885
];
    tform = fitgeotform2d(worldPoints, image_points, 'projective');      % Calculate the homography matrix
    testImagePoints = transformPointsForward(tform, testWorldPoints);   % Transform test points using the homography matrix
    
    if plotting

        imshow(videoFrame); 
        hold on;
    end
    % allImagePoints = [image_points; testImagePoints];
    % % allWorldPoints = [worldPoints; testWorldPoints];
    % 
    % for i = 1:size(allImagePoints, 1)
    %     plot(allImagePoints(i, 1), allImagePoints(i, 2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    %     % text(allImagePoints(i, 1) + 10, allImagePoints(i, 2), sprintf('(%.2f, %.2f, 0)', allWorldPoints(i, 1), allWorldPoints(i, 2)), 'Color', 'red', 'FontSize', 10);
    % end
    % 
    % hold off;

    court_line_indices = [1, 2; 2, 3; 3, 4; 4, 1];  % Tennis court boundary (corners)
    service_line_indices = [1, 2; 3, 4; 5, 6; 7, 8; 9, 10];  % Additional lines (test points)

    court_lines = zeros(size(court_line_indices,1),4);
    % Plot the tennis court boundaries (corners) in red
    for i = 1:size(court_line_indices, 1)
        court_lines(i,:) = [image_points(court_line_indices(i,:),1)', image_points(court_line_indices(i,:), 2)'];
        if plotting
            plot(image_points(court_line_indices(i,:), 1), image_points(court_line_indices(i,:), 2), 'r-', 'LineWidth', 2);
        end
    end

    service_lines = zeros(size(court_line_indices,1),4);
    % Plot the service lines and other internal lines in green
    for i = 1:size(service_line_indices, 1)
        service_lines(i,:) = [testImagePoints(service_line_indices(i,:),1)', testImagePoints(service_line_indices(i,:), 2)'];
        if plotting
            plot(testImagePoints(service_line_indices(i,:), 1), testImagePoints(service_line_indices(i,:), 2), 'g-', 'LineWidth', 2);
        end
    end
    if plotting
        % hold off;
    end
    

    if compute_accuracy

        line_info_court(1,:) = {'mean', 'std'};
        for j = 1:size(court_lines, 1)
            [x,y] = bresenham_line([court_lines(j,1),court_lines(j,3),court_lines(j,2),court_lines(j,4)]);
            I=zeros(1,length(x));
            for i=1:length(x)
                I(i) = videoFrame(y(i),x(i));
            end
            line_info_court(j+1,:) = {mean(I), std(I)};
        end
                
        line_info_service(1,:) = {'mean', 'std'};
        for j = 1:size(service_lines, 1)
            [x,y] = bresenham_line([service_lines(j,1),service_lines(j,3),service_lines(j,2),service_lines(j,4)]);
            I=zeros(1,length(x));
            for i=1:length(x)
                I(i) = videoFrame(y(i),x(i));
            end
            line_info_service(j+1,:) = {mean(I), std(I)};
        end
        line_info = [cell2mat(line_info_court(2:end,:)); cell2mat(line_info_service(2:end,:))];
        means = line_info(:,1);
        good_lines=((mean(means) - std(means)) < (means))';
        valid = isequal(good_lines,ones(size(good_lines)));
    else
        valid = 0;
    end
end
