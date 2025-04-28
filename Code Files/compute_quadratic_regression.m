function result = compute_quadratic_regression(T1,T2)
    result = struct('Frame', [], 'Y', [], 'X', []);
    F1 = [T1.Frame];
    X1 = [T1.X];
    Y1 = [T1.Y];

    X1_trajectory = fit_quadratic_trajectory(F1,X1,0);
    Y1_trajectory = fit_quadratic_trajectory(F1,Y1,0);

    T1_coefficients = [X1_trajectory.coefficients'; Y1_trajectory.coefficients'];
    % plot_parametric_trajectory(T1_coefficients, F1)

    F2 = [T2.Frame];
    X2 = [T2.X];
    Y2 = [T2.Y];

    X2_trajectory = fit_quadratic_trajectory(F2,X2,0);
    Y2_trajectory = fit_quadratic_trajectory(F2,Y2,0);
    
    T2_coefficients = [X2_trajectory.coefficients'; Y2_trajectory.coefficients'];

    % Define F_range based on the overlapping frames
    F_min = min(min(F1), min(F2));
    F_max = max(max(F1), max(F2));
    F_range = [F_min, F_max];

    [F_intersect, x_intersect, y_intersect] = compute_trajectory_intersection(T1_coefficients, T2_coefficients, F_range);
    
    % % Check if an intersection was found
    % if ~isnan(F_intersect)
    %     fprintf('Intersection occurs at Frame: %.6f\n', F_intersect);
    %     fprintf('Intersection Coordinates: (%.6f, %.6f)\n', x_intersect, y_intersect);
    % else
    %     disp('No valid intersection found within the specified frame range.');
    % end

    result.Frame = F_intersect;
    result.Y = y_intersect;
    result.X = x_intersect;
end


function [F_intersect, x_intersect, y_intersect] = compute_trajectory_intersection(T1_coefficients, T2_coefficients, F_range)
    % COMPUTE_TRAJECTORY_INTERSECTION Finds the intersection point and frame number of two parametric trajectories.
    %
    % SYNTAX:
    %   [F_intersect, x_intersect, y_intersect] = compute_trajectory_intersection(T1_coefficients, T2_coefficients, F_range)
    %
    % INPUTS:
    %   T1_coefficients - 2x3 matrix for Trajectory 1
    %   T2_coefficients - 2x3 matrix for Trajectory 2
    %   F_range          - 1x2 vector [F_min, F_max]. The range of F to search for intersection.
    %
    % OUTPUTS:
    %   F_intersect - Frame number where intersection occurs (decimal)
    %   x_intersect - X coordinate at intersection
    %   y_intersect - Y coordinate at intersection

    % ----------------------
    % 1. Input Validation
    % ----------------------
    if size(T1_coefficients,1) ~=2 || size(T1_coefficients,2) ~=3
        error('T1_coefficients must be a 2x3 matrix.');
    end
    if size(T2_coefficients,1) ~=2 || size(T2_coefficients,2) ~=3
        error('T2_coefficients must be a 2x3 matrix.');
    end

    % If F_range is not provided, infer it based on the coefficients
    if nargin < 3 || isempty(F_range)
        % Estimate F_min and F_max based on coefficients (could be improved)
        F_min = 0;
        F_max = 100; % Arbitrary large number; adjust as needed
        F_range = [F_min, F_max];
        warning('F_range not provided. Using default range [0, 100]. Consider specifying F_range for better accuracy.');
    else
        % Ensure F_range is a 1x2 vector
        if ~isvector(F_range) || length(F_range) ~=2
            error('F_range must be a 1x2 vector [F_min, F_max].');
        end
        F_min = F_range(1);
        F_max = F_range(2);
    end

    % ----------------------
    % 2. Extract Coefficients
    % ----------------------
    % Trajectory 1
    a1x = T1_coefficients(1,1);
    b1x = T1_coefficients(1,2);
    c1x = T1_coefficients(1,3);

    a1y = T1_coefficients(2,1);
    b1y = T1_coefficients(2,2);
    c1y = T1_coefficients(2,3);

    % Trajectory 2
    a2x = T2_coefficients(1,1);
    b2x = T2_coefficients(1,2);
    c2x = T2_coefficients(1,3);

    a2y = T2_coefficients(2,1);
    b2y = T2_coefficients(2,2);
    c2y = T2_coefficients(2,3);

    % ----------------------
    % 3. Define Objective Function
    % ----------------------
    % The objective is to minimize the sum of squared differences between the two trajectories
    objective = @(F) ( (a1x*F.^2 + b1x*F + c1x - (a2x*F.^2 + b2x*F + c2x)).^2 + ...
                      (a1y*F.^2 + b1y*F + c1y - (a2y*F.^2 + b2y*F + c2y)).^2 );

    % ----------------------
    % 4. Optimization to Find F_intersect
    % ----------------------
    % Use bounded optimization with fminbnd
    options = optimset('TolX',1e-12, 'TolFun',1e-12, 'MaxIter',1000, 'Display', 'off');

    [F_opt, fval, exitflag] = fminbnd(objective, F_min, F_max, options);

    % ----------------------
    % 5. Compute Intersection Coordinates
    % ----------------------
    x_intersect = a1x * F_opt.^2 + b1x * F_opt + c1x;
    y_intersect = a1y * F_opt.^2 + b1y * F_opt + c1y;
    F_intersect = F_opt;

    % ----------------------
    % 6. (Optional) Display Results
    % ----------------------
    fprintf('Intersection estimated at:\n');
    fprintf('Frame Number (F): %.6f\n', F_intersect);
    fprintf('X Coordinate: %.6f\n', x_intersect);
    fprintf('Y Coordinate: %.6f\n', y_intersect);
end








function plot_parametric_trajectory(T_coefficients, F1_original, plot_title)
    %PLOT_PARAMETRIC_TRAJECTORY Plots a parametric trajectory defined by quadratic equations.
    %
    % SYNTAX:
    %   plot_parametric_trajectory(T_coefficients, F1_original)
    %   plot_parametric_trajectory(T_coefficients, F1_original, plot_title)
    %
    % INPUTS:
    %   T_coefficients - 2x3 matrix. 
    %                    First row: [a_x, b_x, c_x] for x(F1) = a_x*F1^2 + b_x*F1 + c_x
    %                    Second row: [a_y, b_y, c_y] for y(F1) = a_y*F1^2 + b_y*F1 + c_y
    %   F1_original    - Original vector of F1 values used in regression (for reference)
    %   plot_title      - (Optional) String for the plot title. Default: 'Parametric Trajectory'
    %
    % OUTPUT:
    %   A figure displaying the parametric trajectory.

    % Handle optional plot title
    if nargin < 3
        plot_title = 'Parametric Trajectory';
    end

    % Validate T_coefficients size
    if size(T_coefficients, 1) ~= 2 || size(T_coefficients, 2) ~= 3
        error('T_coefficients must be a 2x3 matrix.');
    end

    % Extract coefficients for x and y
    a_x = T_coefficients(1, 1);
    b_x = T_coefficients(1, 2);
    c_x = T_coefficients(1, 3);

    a_y = T_coefficients(2, 1);
    b_y = T_coefficients(2, 2);
    c_y = T_coefficients(2, 3);

    % Generate a smooth range of F1 for plotting
    F1_min = min(F1_original);
    F1_max = max(F1_original);
    F1_curve = linspace(F1_min, F1_max, 500);  % 500 points for smoothness

    % Compute x and y using the quadratic equations
    x = a_x * F1_curve.^2 + b_x * F1_curve + c_x;
    y = a_y * F1_curve.^2 + b_y * F1_curve + c_y;

    % Create the plot
    figure('Name', 'Parametric Trajectory', 'NumberTitle', 'off');
    hold on;
    grid on;

    % Plot the trajectory curve
    plot(x, y, 'r-', 'LineWidth', 2, 'DisplayName', 'Parametric Trajectory');

    % Optionally, plot the original data points for reference
    % Uncomment the following lines if you have original (X1, Y1) data points
    % scatter(X1, Y1, 50, 'bo', 'filled', 'DisplayName', 'Original Data');

    % Label axes
    xlabel('X');
    ylabel('Y');
    title(plot_title);

    % Create legend
    legend('Location', 'best');

    hold off;
end






function trajectory = fit_quadratic_trajectory(X, Y, plot_flag)
    %FIT_QUADRATIC_TRAJECTORY Fits a quadratic (2nd-degree polynomial) to data (X,Y).
    %
    % SYNTAX:
    %   trajectory = fit_quadratic_trajectory(X, Y)
    %   trajectory = fit_quadratic_trajectory(X, Y, plot_flag)
    %
    % INPUTS:
    %   X         - Vector of x-values
    %   Y         - Vector of y-values (same size as X)
    %   plot_flag - (Optional) Boolean. If true (1), plots the fit. Default = true.
    %
    % OUTPUT:
    %   trajectory - A structure with fields:
    %       .coefficients        -> [a, b, c] for the polynomial a*x^2 + b*x + c
    %       .regression_quality  -> R-squared value
    %       .Y_pred             -> Fitted (predicted) values for your original X
    %       .RMSE               -> Root-Mean-Square Error

    % ----------------------
    % 0) Handle inputs
    % ----------------------
    if nargin < 3
        plot_flag = true;  % default to plotting
    end
    
    % Ensure X and Y have compatible shapes
    if ~isequal(size(X), size(Y))
        error('X and Y must have the same size/shape.');
    end
    
    % ----------------------
    % 1) Form the Design Matrix
    % ----------------------
    A = [X(:).^2, X(:), ones(size(X(:)))];
    
    % ----------------------
    % 2) Solve for [a, b, c]
    % ----------------------
    coefficients = A \ Y(:);  % Solve for [a,b,c] using least squares
    
    % ----------------------
    % 3) Compute predicted Y and R-squared
    % ----------------------
    Y_pred = A * coefficients;
    SS_res = sum((Y(:) - Y_pred).^2);        % Residual sum of squares
    SS_tot = sum((Y(:) - mean(Y(:))).^2);    % Total sum of squares
    R_squared = 1 - (SS_res / SS_tot);
    
    % ----------------------
    % 4) Compute RMSE (optional but often useful)
    % ----------------------
    MSE  = SS_res / length(Y);
    RMSE = sqrt(MSE);
    
    % ----------------------
    % 5) Store results in output structure
    % ----------------------
    trajectory = struct();
    trajectory.coefficients        = coefficients;
    trajectory.regression_quality  = R_squared;
    trajectory.Y_pred              = Y_pred;
    trajectory.RMSE                = RMSE;
    
    % ----------------------
    % 6) Optional Plot
    % ----------------------
    if plot_flag
        figure('Name','Quadratic Regression');
        hold on;
        
        % Scatter the original data
        scatter(X, Y, 'bo', 'DisplayName', 'Data');
        
        % Plot the fitted curve
        X_curve = linspace(min(X), max(X), 200);
        Y_curve = coefficients(1)*X_curve.^2 + ...
                  coefficients(2)*X_curve + ...
                  coefficients(3);
        plot(X_curve, Y_curve, 'r-', 'LineWidth', 2, 'DisplayName', 'Quadratic Fit');
        
        % Create a nice label for the polynomial
        equation_str = sprintf('y = %.3f x^2 + %.3f x + %.3f', ...
            coefficients(1), coefficients(2), coefficients(3));
        
        % Place equation text near top-left corner of axes
        xRange = xlim;
        yRange = ylim;
        xPos = xRange(1) + 0.05*range(xRange);
        yPos = yRange(2) - 0.05*range(yRange);
        
        text(xPos, yPos, equation_str, ...
             'FontSize', 12, 'Color','red','FontWeight','bold');
        
        % Label axes
        xlabel('X');
        ylabel('Y');
        title('Quadratic Regression Fit');
        legend('Location','best');
        grid on;
        hold off;
    end
end











% function trajectory = compute_trajectory_coeffients(X,Y)
%     % Write a function that calculates a quadratic trajectory given x and y
%     % Output the coefficients and regression coefficient as a structure
%     A = [X.^2,X,ones(size(X))];
%     coefficients = A\Y; % Solve for [a,b,c] using least squares regression
% 
%     % Compute predicted Y values based on the fitted quadratic model
%     Y_pred = A * coefficients;
% 
%     % Compute R-squared value to evaluate regression quality
%     SS_res = sum((Y - Y_pred).^2);  % Residual sum of squares
%     SS_tot = sum((Y - mean(Y)).^2); % Total sum of squares
%     R_squared = 1 - (SS_res / SS_tot);  % R-squared formula
% 
%     % Store results in the output structure
%     trajectory = struct('coefficients', coefficients, 'regression_quality', R_squared);
% 
% 
%     % Optional Plotting
%     plot_flag = 1;
%     if plot_flag
%         figure;
%         hold on;
% 
%         % Scatter plot of actual data points
%         scatter(X, Y, 'bo', 'DisplayName', 'Actual Data');
% 
%         % Plot the regression curve
%         X_curve = linspace(min(X), max(X), 100);  % Generate smooth X values for the curve
%         Y_curve = coefficients(1) * X_curve.^2 + coefficients(2) * X_curve + coefficients(3);
%         plot(X_curve, Y_curve, 'r-', 'LineWidth', 2, 'DisplayName', 'Quadratic Fit');
% 
%         % Display regression equation on the plot
%         equation_str = sprintf('y = %.3fx^2 + %.3fx + %.3f', coefficients(1), coefficients(2), coefficients(3));
%         text(min(X), max(Y), equation_str, 'FontSize', 12, 'Color', 'red', 'FontWeight', 'bold');
% 
%         % Axis Labels and Title
%         xlabel('X values');
%         ylabel('Y values');
%         title('Quadratic Regression Fit');
%         legend;
%         grid on;
%         hold off;
%     end
% end