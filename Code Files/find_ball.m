function ball_xy_size = find_ball(videoFrame, prevFrame, thresh, ball_xy_size, corners)
    if (isequal(ball_xy_size,0) || ball_xy_size(:,end)==0)
        xpos = 0;
        ypos = 0;
        size = 0;
    else
        xpos=ball_xy_size(1,end);
        ypos=ball_xy_size(2,end);
        size=ball_xy_size(3,end);
    end

    spatial_filtering = false;
    fft_filtering = true;

    %mask4 = mask1.*mask4;

    mask = imabsdiff(prevFrame,videoFrame);
    mask2=imgaussfilt(mask,2);
    mask3= (mask2>20).*5;
    %mask4 = imresize(mask3,0.2);
    mask4 = rgb2gray(mask3);
    
    if any(mask4(:))
        if spatial_filtering
            kernel_laplacian =  [0,  0, -1,  0,  0;...
                                 0, -1, -2, -1,  0;...
                                -1, -2, 16, -2, -1;...
                                 0, -1, -2, -1,  0;...
                                 0,  0, -1,  0,  0]./256;
            Y = spatial_filter(videoFrame, kernel_laplacian);
            I=rgb2gray(Y);
            I=im2double(I);
            I(I<0.2)=0;
            mask1 = I;
            %imshow(I)
            mask4 = mask1.*mask4;
        end


        [y,x] = find(mask4);
        xyPoints=[x,y];
        ep=5;
        minPts=6;
        clusters = dbscan(xyPoints,ep,minPts);
        clusters(clusters==-1)=0;

        size_list = zeros(1,max(clusters));
        xpos_list = zeros(1,max(clusters));
        ypos_list = zeros(1,max(clusters));
        distance = zeros(1,max(clusters));

        for i=1:max(clusters) % Will go back and calculate ball cluster later (lets cheat for now)
            size_list(i) = sum(clusters==i);
            xpos_list(i) = mean(x(clusters==i));
            ypos_list(i) = mean(y(clusters==i));
            if size_list(i)>100
                distance(i)=10^6;
            else
                distance(i) = (size_list(i)-size)^2+(xpos_list(i)-xpos)^2+(ypos_list(i)-ypos)^2;
            end
        end
        mindist = min(distance);
        
        

        if (mindist < thresh)
            thresh = 2000;
            idx = find(distance==mindist);
            size = size_list(idx);
            xpos = xpos_list(idx);
            ypos = ypos_list(idx);
            distances(end+1) = mindist;
        else
            thresh = 20000;
            idx=-1;
            distances(end+1) = 20000;
        end

        
        if ~isequal(prevmask,0)
            mask5=mask4&prevmask;
            if idx == -1
                mask6=mask4;
            else
            mask6=coordstoimage(mask4,x(clusters==idx),y(clusters==idx));
            end
            % if isequal(mask6,0)
            %     mask6=mask5;
            % end
            if mask_array==0
                mask_array=mask6;
            else
                mask_array(:,:,end+1)=mask6;
            end
            
            x_list(end+1) = xpos;
            y_list(end+1) = ypos;
            sizes_list(end+1) = size;
            frame_count_list(end+1) = frameCounter;
            %figure;imshow(mask5)
        end
    
        prevmask = mask4;
    else
        ball_xy_size = [0,0,0];
    end
    % if any(mask4(:))
    %     [y,x] = find(mask4);
    %     xyPoints=[x,y];
    %     ep=5;
    %     minPts=25;
    %     clusters = dbscan(xyPoints,ep,minPts);
    % 
    %     % mask5 = zeros(size(mask4));
    %     a=[];
    %     for i=1:length(unique(clusters))
    %         if sum(clusters==i) < 200 
    %             a(i) = i;
    %         end
    %     end
    %     b = ismember(clusters,a);
    %     newx=x(b);
    %     newy=y(b);
    %     newclusters=clusters(b);
    %     mask5 = coordstoimage(mask4,newx,newy);
    % 
    % 
    % 
    % 
    %     xyPoints=[newx,newy];
    %     ep=30;
    %     minPts=60;
    %     clusters = dbscan(xyPoints,ep,minPts);
    % 
    %     % mask5 = zeros(size(mask4));
    % 
    %     b = clusters==mode(clusters);
    %     newx=newx(b);
    %     newy=newy(b);
    %     newclusters=clusters(b);
    %     mask6 = coordstoimage(mask5,newx,newy);
    % 
    %     figure;imshow(mask4)
    % 
    % 
    % end

    % 
    % if any(mask(:))
    %     [centers, radii] = imfindcircles(mask, [3 10], 'Sensitivity', 0.85);
    %     [centers2, radii2] = imfindcircles(videoFrame, [3 10], 'Sensitivity', 0.85);
    % 
    % 
    %     if ~(isempty(centers) | isempty(centers2))
    % 
    %         % validCenters = [];
    %         % validRadii = [];
    %         % 
    %         % for i = 1:length(radii)
    %         %     hsvFrame = rgb2hsv(videoFrame);
    %         % 
    %         %     [rows, cols] = size(videoFrame);
    %         %     [xx, yy] = ndgrid((1:rows) - centers(i, 2), (1:cols) - centers(i, 1));
    %         %     circleMask = (xx.^2 + yy.^2) <= radii(i)^2;
    %         % 
    %         %     circleHueValues = hsvFrame(:,:,1);
    %         %     meanHue = mean(circleHueValues(circleMask));
    %         % 
    %         %     if meanHue >= hueMin && meanHue <= hueMax
    %         %         validCenters = [validCenters; centers(i, :)];  
    %         %         validRadii = [validRadii; radii(i)];  
    %         %     end
    %         % end
    % 
    % 
    % 
    %         videoFrameWithCircles = insertShape(videoFrame, 'Circle', [centers, radii], 'LineWidth', 3, 'Color', 'red');
    % 
    %         imshow(videoFrameWithCircles); 
    %         title('Detected Tennis Balls');
    %         disp('Frame: ' + string(frameCounter))
    %         for i = 1:size(centers, 1)
    %             fprintf('Ball %d: X = %.2f, Y = %.2f, Radius = %.2f\n', i, centers(i, 1), centers(i, 2), radii(i));
    %         end
    %     end
    % end