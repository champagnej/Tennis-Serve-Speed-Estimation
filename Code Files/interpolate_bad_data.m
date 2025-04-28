function corners = interpolate_bad_data(corners)

    smoothed_data = corners.smoothed_data;
    num_frames = length(smoothed_data);
    
    i = 1;
    while i <= num_frames
        if isequal(smoothed_data{i}, 0) % Found a zero (bad data)
            % Find the last valid data point
            prev_idx = i - 1;
            while prev_idx > 0 && isequal(smoothed_data{prev_idx}, 0)
                prev_idx = prev_idx - 1;
            end
            if prev_idx == 0
                warning('No previous valid data found. Skipping interpolation for early bad data.');
                i = i + 1;
                continue;
            end
            prev_data = smoothed_data{prev_idx};
            
            % Find the next valid data point
            next_idx = i + 1;
            while next_idx <= num_frames && isequal(smoothed_data{next_idx}, 0)
                next_idx = next_idx + 1;
            end
            if next_idx > num_frames
                warning('No next valid data found. Skipping interpolation for remaining bad data.');
                break;
            end
            next_data = smoothed_data{next_idx};
            
            % Number of bad frames between prev and next
            num_bad_frames = next_idx - prev_idx - 1;
            
            % Perform interpolation for the indices
            interpolated_values = interpolate_values(prev_data, next_data, num_bad_frames);
            
            % Replace the bad frames with the interpolated values
            smoothed_data(prev_idx+1:next_idx-1) = interpolated_values;
            
            % Skip past the interpolated frames
            i = next_idx;
        else
            i = i + 1;
        end
    end
    
    % Update corners with interpolated smoothed data
    corners.smoothed_data = smoothed_data;
end


function interpolated_values = interpolate_values(start_value, end_value, num_steps)
    % Interpolate between start_value and end_value over num_steps points
    interpolated_values = cell(num_steps, 1); % Initialize cell array for interpolated values
    
    for i = 1:num_steps
        t = i / (num_steps + 1);
        interpolated_values{i} = (1 - t) * start_value + t * end_value;  % Linear interpolation
    end
end