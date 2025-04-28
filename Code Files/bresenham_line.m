function [x_coord, y_coord] = bresenham_line(point) % [y0, x0, y1, x1]
    point=round(point);
    if abs(point(4) - point(2)) > abs(point(3) - point(1))       % If the line is steep
        x0 = point(2); y0 = point(1); x1 = point(4); y1 = point(3);  % Swap coordinates to make it non-steep
        token = 1;                                              % Mark it as steep
    else
        x0 = point(1); y0 = point(2); x1 = point(3); y1 = point(4);
        token = 0; 
    end
    
    if x0 > x1
        % Swap starting and ending points if x0 is greater than x1
        temp1 = x0; x0 = x1; x1 = temp1;
        temp2 = y0; y0 = y1; y1 = temp2;
    end
    
    dx = abs(x1 - x0);                              % Distance to travel in x-direction
    dy = abs(y1 - y0);                              % Distance to travel in y-direction
    sx = sign(x1 - x0);                             % Step for x direction
    sy = sign(y1 - y0);                             % Step for y direction
    
    x = x0; y = y0;                                 % Starting coordinates
    param = 2 * dy - dx;                            % Error parameter initialization
    
    % Initialize coordinate arrays
    x_coord = zeros(1, dx + 1); 
    y_coord = zeros(1, dx + 1);
    
    for i = 1:dx+1                                  % MATLAB index starts at 1, so adjust accordingly
        x_coord(i) = x;                             % Save current x
        y_coord(i) = y;                             % Save current y
        
        param = param + 2 * dy;                     % Modify error parameter
        if param > 0                                % If error exceeds threshold
            y = y + sy;                             % Adjust y based on the sign of slope
            param = param - 2 * dx;                 % Adjust error back
        end
        x = x + sx;                                 % Increment x based on step
    end
    
    if token                                        % If the line was steep, swap back
        temp = y_coord;
        y_coord = x_coord;
        x_coord = temp;
    end
    
end




% 
% 
% function [x_coord,y_coord] = bresenham_line(point)
% 
% 
%     if (abs(point(4)-point(2)) > abs(point(3)-point(1)))       % If the line is steep                                
%         x0 = point(2);y0 = point(1); x1 = point(4);y1=point(3);% then it would be converted to 
%         token =1;                                              % non steep by changing coordinate
%     else
%         x0 = point(1);y0 = point(2); x1 = point(3);y1=point(4);
%         token = 0; 
%     end
%     if(x0 >x1)
%         temp1 = x0; x0 = x1; x1 = temp1;
%         temp2 = y0; y0 = y1; y1 = temp2;
%     end
%     dx = abs(x1 - x0) ;                              % Distance to travel in x-direction
%     dy = abs(y1 - y0);                               % Distance to travel in y-direction
%     sx = sign(x1 - x0);                              % sx indicates direction of travel in X-dir
%     sy = sign(y1 - y0);                              % Ensures positive slope line
% 
%     x = x0; y = y0;                                  % Initialization of line
%     param = 2*dy - dx ;                              % Initialization of error parameter
%     for i = 0:dx-1                                   % FOR loop to travel along X
%         x_coord(i+1) = x;                            % Saving in matrix form for plot
%         y_coord(i+1) = y;
% 
%         param = param + 2*dy;                        % parameter value is modified
%         if (param >0)                                % if parameter value is exceeded
%             y = y +1*sy;                             % then y coordinate is increased
%             param = param - 2*(dx );                 % and parameter value is decreased
% 
%         end
%         x = x + 1*sx;                                % X-coordinate is increased for next point
%     end
% 
% 
%     if(token)
%         temp2 = y_coord;
%         y_coord = x_coord;
%         x_coord = y_coord;
%     end
% end