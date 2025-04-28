% function [coefficients, R_squared] = fit_parabolic_curve(Time, Position1, Position2)
% % FIT_PARABOLIC_CURVE Fits a parabolic model to the given data.
% % Inputs:
% %   Time - Array of time points (independent variable).
% %   Position - Array of position values (dependent variable).
% % Outputs:
% %   coefficients - Coefficients [a, b, c] of the fitted model y = at^2 + bt + c.
% %   R_squared - Coefficient of determination (R^2) for the fit.
% 
%     % Check input sizes
%     if length(Time) ~= length(Position1)
%         error('Time and Position must have the same length.');
%     end
% 
%     % Construct the design matrix for the quadratic model
%     X = [Time.^2, Time, ones(length(Time), 1)];
% 
%     % Perform least squares fitting
%     coefficients = (X' * X) \ (X' * Position1);
% 
%     % Predicted values
%     Predicted = X * coefficients;
% 
%     % Compute R^2
%     SS_total = sum((Position - mean(Position)).^2); % Total sum of squares
%     SS_residual = sum((Position - Predicted).^2);   % Residual sum of squares
%     R_squared = 1 - (SS_residual / SS_total);      % Coefficient of determination
% end
% 





function [coefficients, R_squared] = fit_parabolic_curve(Time, Position)
% FIT_PARABOLIC_CURVE Fits a parabolic model to the given data.
% Inputs:
%   Time - Array of time points (independent variable).
%   Position - Array of position values (dependent variable).
% Outputs:
%   coefficients - Coefficients [a, b, c] of the fitted model y = at^2 + bt + c.
%   R_squared - Coefficient of determination (R^2) for the fit.

    % Check input sizes
    if length(Time) ~= length(Position)
        error('Time and Position must have the same length.');
    end

    % Construct the design matrix for the quadratic model
    X = [Time.^2, Time, ones(length(Time), 1)];

    % Perform least squares fitting
    coefficients = (X' * X) \ (X' * Position);

    % Predicted values
    Predicted = X * coefficients;

    % Compute R^2
    SS_total = sum((Position - mean(Position)).^2); % Total sum of squares
    SS_residual = sum((Position - Predicted).^2);   % Residual sum of squares
    R_squared = 1 - (SS_residual / SS_total);      % Coefficient of determination
end

