function corners = find_corners(videoFrame, prev_corner_details)
    if ~isempty(prev_corner_details)
        old_top_left_corner = prev_corner_details.top_left_corner;
        corner_details.valid = true;
    end

    % kernel_laplacian =  [0,  0, -1,  0,  0;...
    %                      0, -1, -2, -1,  0;...
    %                     -1, -2, 16, -2, -1;...
    %                      0, -1, -2, -1,  0;...
    %                      0,  0, -1,  0,  0]./256;
    % 
    % 
    % highpass(videoFrame, kernel_laplacian)

    % function [cL,cH] = getfilters(radius,Size)
    %     [x,y] = meshgrid(-Size(2)/2:Size(2)/2-1,-Size(1)/2:Size(1)/2-1);
    %     z = sqrt(x.^2+y.^2);
    %     cL = z < radius;
    %     cH = ~cL;
    % end
    videoFrame_color = videoFrame;
    videoFrame = im2gray(videoFrame);    
    videoFrame2 = imadjust(videoFrame,stretchlim(videoFrame),[]);


    blurAmount = 2;
    kernelSize = 2 * ceil(2 * blurAmount) + 1;
    gaussianFilter = fspecial('gaussian', [kernelSize kernelSize], blurAmount);
    videoFrame_Blurred = imfilter(videoFrame, gaussianFilter, 'same');
    videoFrame_Sharpened = imsharpen(videoFrame,Radius=2,Amount=1);

    lightEdgeThreshold = 0.3;
    % BW = edge(videoFrame_Blurred);
    BW = edge(videoFrame_Sharpened, 'Canny', lightEdgeThreshold/2);
    
    % SE=[0 0 0 1 0 0 0;0 0 1 1 1 0 0;0 1 1 1 1 1 0;1 1 1 1 1 1 1;0 1 1 1 1 1 0;0 0 1 1 1 0 0;0 0 0 1 0 0 0];
    % A1=imdilate(BW,SE);
    % SE = [0 1 0; 1 1 1; 0 1 0];
    % % SE=[0 0 0 1 0 0 0;0 0 1 1 1 0 0;0 1 1 1 1 1 0;1 1 1 1 1 1 1;0 1 1 1 1 1 0;0 0 1 1 1 0 0;0 0 0 1 0 0 0];
    % A2=imerode(A1,SE);
    % A2=imerode(A2,SE);
    % A2=imerode(A2,SE);
    % BW=imerode(A2,SE);
    % % BW = edge(BW, 'Canny', lightEdgeThreshold/2);

    



    % Create binary opening masks for each angle line is at
    % Create for loop for all angles
    % Create structuring element for each angle (with specified length)
    % Perform opening
    % Function erosion (struct, 
    % Function dilation


    % Combine all masks using logical OR operator
    % Have angle change as a parameter that can be tuned


    % Perform histogram equalization?


    Blur_BW = imfilter(BW.*255, gaussianFilter, 'same');
    Blur_BW_thresh = Blur_BW > 10;


    % Set parameters
    angleStep = 1;  % Angle step size (can be adjusted)
    lineLength = 400; % Length of structuring element
    edgeThreshold = 20;

    % Apply the function
    resultMask = angle_based_opening(Blur_BW_thresh, angleStep, lineLength, edgeThreshold);

    [maskheight,maskwidth] = size(resultMask);
    minClusterSize = maskheight*maskwidth * 0.01; % 1% of screen should be tennis court, filter out small clusters
    minpts = 15;
    epsilon = 15;
    filteredMask_corners = filter_mask_using_dbscan(resultMask, minpts, minClusterSize, epsilon);
    
    se = strel('disk', 3);
    openedMask = imopen(filteredMask_corners, se);

    corners = find_bounding_box(openedMask);


end

% 
% 
% 
%     % dilationAmount = 8;
%     % se = strel('line', dilationAmount, 0);
%     % BW = imdilate(BW, se);
% 
%     [H,theta,rho] = hough(cannyResult);
% 
%     P = houghpeaks(H,20,'threshold',ceil(0.05*max(H(:))));
% 
% 
%     % figure
%     % imshow(imadjust(rescale(H)),[],...
%     %        'XData',theta,...
%     %        'YData',rho,...
%     %        'InitialMagnification','fit');
%     % xlabel('\theta (degrees)')
%     % ylabel('\rho')
%     % axis on
%     % axis normal 
%     % hold on
%     % colormap(gca,hot)
% 
%     x = theta(P(:,2));
%     y = rho(P(:,1));
%     % plot(x,y,'s','color','black');
%     % 
%     % 
%     lines = houghlines(BW,theta,rho,P,'FillGap', 10,'MinLength',200);
%     % 
%     % 
%     % plotlines(lines, videoFrame)
%     % 
% 
%     meanlines = zeros(1,length(lines));
%     stdlines = zeros(1,length(lines));
% 
% 
%     line_info(1,:) = {'mean blur', 'mean', 'std blur', 'std'};
%     for j=1:length(lines)
%         point = [lines(j).point1(1), lines(j).point1(2), lines(j).point2(1), lines(j).point2(2)];
%         [x,y] = bresenham_line(point);
%         I=zeros(1,length(x));
%         for i=1:length(x)
%             Iblur(i) = videoFrame_Blurred(y(i),x(i));
%             I(i) = videoFrame(y(i),x(i));
%             %videoFrame(y(i),x(i)) = 0;
%             %disp(i)
%         end
%         % figure,imshow(videoFrame)
%         % hold on;
%         % plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
%         % hold off;
%         line_info(j+1,:) = {mean(double(Iblur)), mean(I), std(double(Iblur)), std(I)};
%         %stdlines(j) = std(I);
%     end
%     meansums = cell2mat(line_info(2:end,1))+cell2mat(line_info(2:end,2));
%     a=((mean(meansums) - 0.5*std(meansums)) < (meansums))';
%     b=stdlines<40;
%     c=a&b;
%     lines2 = lines(c);
% 
%     % allPoints = findUsefulIntersections(lines, 3, 3, width(videoFrame)-3, height(videoFrame)-3);
%     intersectionPoints = findUsefulIntersections(lines2, 3, 3, width(videoFrame)-3, height(videoFrame)-3);
% 
% 
% 
% 
% 
% 
% 
% 
%     % plotlines(lines2, videoFrame);
% 
%     % 
%     % figure,imshow(videoFrame)
%     % hold on;
%     % plot(allPoints(:,1), allPoints(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
%     % hold off;
% 
% 
% 
%     % Find min/max x and y components of median lines to take the lines
%     % with the edges
% 
% 
% 
% 
% 
%     try
%         k = convhull(intersectionPoints(:,1), intersectionPoints(:,2));
%     catch
%         corners = 0;
%         corner_details.valid=0;
%         corner_details.top_left_corner = prev_corner_details.top_left_corner;
%         return
%     end
% 
%     hull_points = intersectionPoints(k, :);
%     hull_points(end+1,1:2)=hull_points(2,1:2); % Append this for angle calculation
%     filtered_points = [];
%     for i=1:length(hull_points)-2
%         p1 = hull_points(i,:);
%         p2 = hull_points(i+1,:);
%         p3 = hull_points(i+2,:);
%         angle = angleBetweenLines(p1,p2,p2,p3);
% 
%         if abs(angle) >= 1
%             filtered_points = [filtered_points; p2];
%         end
%     end
% 
%     if ~(size(filtered_points,1) == 4)
%         corner_details.valid = false;
%         corners = zeros(4,2);
%         if ~isempty(prev_corner_details)
%             corner_details.top_left_corner = old_top_left_corner;
%         end
%         return
%     end
% 
%     % figure,imshow(videoFrame)
%     % hold on;
%     % plot(filtered_points(:,1), filtered_points(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
%     % hold off;
%     extra_plots=0;
%     if extra_plots
%         figure,imshow(videoFrame)
%         hold on;
%         plot(intersectionPoints(:,1), intersectionPoints(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
%         hold off;
% 
%         figure,imshow(videoFrame)
%         hold on;
%         plot(filtered_points(:,1), filtered_points(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
%         hold off;
%     end
% 
%     % Make sure top left corner is always on top
%     if isempty(prev_corner_details)
%         distances = filtered_points(:,1).^2 + filtered_points(:,2).^2;
%         [~, top_left_corner_idx] = min(distances);
%         top_left_corner = filtered_points(top_left_corner_idx,:);
%     else
%         top_left_corner_idx = mindist(old_top_left_corner, filtered_points);
%         top_left_corner = filtered_points(top_left_corner_idx,:);
%     end
% 
%     corner_details.top_left_corner = top_left_corner;
% 
%     % Make sure the point marked 'top left corner' always comes first in index
%     filtered_points = [filtered_points(top_left_corner_idx:end, :); filtered_points(1:top_left_corner_idx-1, :)];
% 
%     corners = filtered_points;
% 
%     plotting=0;
%     compute_accuracy=1;
%     corner_details.valid=find_tennis_points(filtered_points, plotting, videoFrame_Blurred, compute_accuracy);
% 
%     %corners = allPoints;
% 
%     % Add another row for probability for each corner
% 
% 
%     % figure;
%     % imshow(videoFrame);
%     % hold on;
%     % plot(hull_points(:,1), hull_points(:,2), 'b--', 'LineWidth', 1);
%     % hold off;
% 
% 
%     % for i = 1:length(lines2)
%     %     lines2(i).median = (lines2(i).point1 + lines2(i).point2) / 2;
%     % end
%     % 
%     % x_values = arrayfun(@(s) s.median(1), lines2);
%     % y_values = arrayfun(@(s) s.median(2), lines2);
%     % 
%     % [min_x, min_x_idx] = min(x_values);
%     % [max_x, max_x_idx] = max(x_values);
%     % [min_y, min_y_idx] = min(y_values);
%     % [max_y, max_y_idx] = max(y_values);
%     % 
%     % unique_indices = unique([min_x_idx, max_x_idx, min_y_idx, max_y_idx]);
%     % 
%     % lines3 = lines2(unique_indices);
%     % %plotlines(lines3, videoFrame);
%     % 
%     % intersectionPoints = findUsefulIntersections(lines3, 0, 0, width(videoFrame), height(videoFrame));
%     % 
%     % % A=string(intersectionPoints(:,1))+string(intersectionPoints(:,2));
%     % % B=unique(A);
%     % % 
%     % % 
%     % % distance_squared = ((intersectionPoints(i,1))-intersectionPoints(j,1))^2+((intersectionPoints(i,2))-intersectionPoints(j,2))^2;
%     % 
%     % 
%     % figure,imshow(videoFrame)
%     % hold on;
%     % plot(intersectionPoints(:,1), intersectionPoints(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
%     % hold off;
%     % 
% 
%     % % Try taking fft, remove low frequencies (set to 0), take ifft.
%     % % videoFrame = im2gray(videoFrame);    
%     % % ft = fftshift(fft2(videoFrame));
%     % % [cl cH] = getfilters(20,size(videoFrame));
%     % % h_pass = ft.*cH;
%     % 
%     % % high_filtered_image = ifft2(ifftshift(h_pass), 'symmetric');
%     % %D(height(D)/2 - 1:height(D)/2 + 1,length(D)/2 - 1:length(D)/2 + 1) = 0;
%     % 
%     % %A = ifft2(D);
%     % 
%     % 
%     % 
%     % 
%     % % kernel_laplacian =  [0,  0, -1,  0,  0;...
%     % %                      0, -1, -2, -1,  0;...
%     % %                     -1, -2, 16, -2, -1;...
%     % %                      0, -1, -2, -1,  0;...
%     % %                      0,  0, -1,  0,  0]./256;
%     % % 
%     % % Y = spatial_filter(videoFrame, kernel_laplacian);
%     % % I=rgb2gray(Y);
%     % % I=im2double(I);
%     % % I(I<0.2)=0;
%     % % mask1 = I;
%     % %imshow(I)
%     % 
%     % % max(hough(high_filtered_image))
%     % if length(intersectionPoints) == 4
%     %     corners = intersectionPoints;
%     % end
% 
% 
% 
% end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
