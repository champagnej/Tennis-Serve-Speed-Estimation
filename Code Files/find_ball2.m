function [details, data] = find_ball2(nextFrame, currentFrame, prevFrame, thresh, details)
    
    % nextFrame = nextFrame;
    % currentFrame = currentFrame;
    % prevFrame = prevFrame;
    


    % Preprocessing and mask generation
    maskprev = imabsdiff(prevFrame, currentFrame);
    masknext = imabsdiff(currentFrame, nextFrame);

    gray_maskprev = im2gray(maskprev);
    gray_masknext = im2gray(masknext);
    gray_currentFrame = im2gray(currentFrame);


    mask = (gray_maskprev > 10) & (gray_masknext > 10);
    mask1 = (gray_masknext + gray_maskprev) .* uint8(mask);
    threshold_percent = 0.2;
    mask2 = uint8(mask1 > (threshold_percent * max(mask1(:)))) .* mask1;
    mask3 = 0.5 * (2 * imgaussfilt(mask2, 2) + mask2);
    
    threshold_percent = 0.3;
    mask3 = uint8(mask3 > (threshold_percent * max(mask3(:)))) .* mask3;

    mask3 = imdilate(mask3, strel('disk', 4));

    BW = edge(gray_currentFrame, 'Canny', 0.05);
    mask4 = uint8(BW) .* mask3;
    mask5 = imdilate(mask4, strel('disk', 3));

    mask6 = mask5 > 10;

    if any(mask6(:))
        % Perform clustering
        [y, x] = find(mask6); % Get all valid points in the mask
        xyPoints = [x, y];
        ep = 10;
        minPts = 10;
        clusters = dbscan(xyPoints, ep, minPts);
        clusters(clusters == -1) = 0; % Mark noise points as cluster 0

        % Initialize data arrays
        size_list = zeros(1, max(clusters));
        xpos_list = zeros(1, max(clusters));
        ypos_list = zeros(1, max(clusters));
        top_y_list = zeros(1, max(clusters));
        top_x_list = zeros(1, max(clusters));

        % Loop through each cluster
        for i = 1:max(clusters)
            cluster_idx = (clusters == i); % Points belonging to cluster i
            size_list(i) = sum(cluster_idx); % Cluster size
            xpos_list(i) = mean(x(cluster_idx)); % Mean x position
            ypos_list(i) = mean(y(cluster_idx)); % Mean y position

            % Find top_y and corresponding x
            cluster_y = y(cluster_idx);
            cluster_x = x(cluster_idx);
            top_y = min(cluster_y); % Topmost y value
            top_x = mean(cluster_x(cluster_y == top_y)); % Average x for points with top_y

            top_y_list(i) = top_y; % Store top_y
            top_x_list(i) = top_x; % Store corresponding top_x
        end

        % Combine all data into the output structure
        data = [xpos_list; ypos_list; size_list; top_y_list; top_x_list];
        details = 0; % Update details if necessary
    else
        % No clusters found
        data = [];
        details = 0;
    end

    plot=0;
    if plot
        xpos_list = data(1, :); 
        ypos_list = data(2, :); 
        
        imshow(currentFrame); 
        hold on; 
        
        scatter(xpos_list, ypos_list, 100, 'r', 'o', 'LineWidth', 1.5);
        
        title('Tennis Ball Tracking Points');
        xlabel('X Position');
        ylabel('Y Position');
        
        hold off;
    end
end




















































% function [details, data] = find_ball2_test(nextFrame, currentFrame, prevFrame, thresh, details)
% 
%     maskprev = imabsdiff(prevFrame,currentFrame);
%     masknext = imabsdiff(currentFrame,nextFrame);
%     mask=(masknext>10)&(maskprev>10);
%     mask1 = (masknext+maskprev).*uint8(mask);
%     threshold_percent = 0.6;
%     mask2= uint8(mask1>(threshold_percent.*max(max(mask1)))).*mask1;
%     mask3=0.5*(2*imgaussfilt(mask2,2)+mask2);
% 
%     threshold_percent = 0.3;
%     mask3= uint8(mask3>(threshold_percent.*max(max(mask3)))).*mask3;
% 
% 
%     mask3=imdilate(mask3, strel('disk',4));
% 
%     BW = edge(currentFrame, 'Canny', 0.15);
%     mask4 = uint8(BW).*mask3;
%     mask5=imdilate(mask4,strel('disk',3));
% 
%     mask7 = edge(mask5, 'Canny', 0.15);
% 
%     mask6=mask5>0;
%     max_size = 8;
% 
% 
%     mask4=mask5;
%     if any(mask4(:))
%         clustering=1;
%         if clustering == 1
%             [y,x] = find(mask4);
%             xyPoints=[x,y];
%             ep=15;
%             minPts=10;
%             clusters = dbscan(xyPoints,ep,minPts);
%             clusters(clusters==-1)=0;
%         else
% 
%         end
% 
% 
% 
%         % Logic to track each cluster
%         % Track size of each cluster and central location
%         % compute min distance between clusters per frame
% 
% 
%         size_list = zeros(1,max(clusters));
%         xpos_list = zeros(1,max(clusters));
%         ypos_list = zeros(1,max(clusters));
%         % distance = zeros(1,max(clusters));
% 
%         for i=1:max(clusters) % Will go back and calculate ball cluster later (lets cheat for now)
%             size_list(i) = sum(clusters==i);
%             xpos_list(i) = mean(x(clusters==i));
%             ypos_list(i) = mean(y(clusters==i));
%         end
% 
%         % Function to compare previous cluster to current cluster
% 
%         if isempty(details)
%             % details={};
%             % prev_details.size_list=0;
%             % prev_details.xpos_list=0;
%             % prev_details.ypos_list=0;
%         end
%         data = [xpos_list;ypos_list;size_list];
%         details = 0;
% 
% 
% 
% 
%     else
%         ball_xy_size = [0,0,0];
%     end
% 
% end



