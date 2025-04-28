function filtered_angles = filter_angles(input_clusters,max_angle_change, hard_max_angle_change, min_consecutive_small_angles)
    filtered_angles = [];
    starting_max_angle_change = max_angle_change;
    for i=1:length(input_clusters)
        max_angle_change = starting_max_angle_change;
        current_trajectory = input_clusters(i).Trajectory;
        trajectory_length = length(current_trajectory);


        filter = zeros(1,trajectory_length-3);
        

        find_max = 1;
        if find_max == 1
            current_max = max([current_trajectory.Absolute_Angle_Change]);
            if current_max >  max_angle_change
                max_angle_change = current_max;
                if current_max > hard_max_angle_change
                    max_angle_change = hard_max_angle_change;
                end
            end
        end

        for j=3:length(current_trajectory)-1
            if current_trajectory(j).Absolute_Angle_Change >= max_angle_change
                % Create filter of zeros and ones
                filter(j-2)=0;
            else
                filter(j-2)=1;
            end
        end
        if all(filter==1)
            filtered_angles(end+1).Trajectory = input_clusters(i).Trajectory;
            continue;
        end
        first_one_index = find(filter == 1, 1, 'first');
        if isempty(first_one_index)
            % Remove cluster and continue
            continue
        end

        % Track consecutive 1's after first occurence
        [consecutive_ones_list, starting_indices_list] = analyze_consecutive_ones(filter);


        if max(consecutive_ones_list) > min_consecutive_small_angles
            valid_trajectory = consecutive_ones_list > min_consecutive_small_angles;
            for j=1:length(consecutive_ones_list)
                if valid_trajectory(j) == 0
                    continue
                end
                starting_idx = starting_indices_list(j);
                ending_idx = starting_indices_list(j)+consecutive_ones_list(j)-1;
                % Trim current_trajectory to start and end
                filtered_angles(end+1).Trajectory = input_clusters(i).Trajectory(starting_idx:ending_idx);
            end
        else
            % Remove cluster and continue
            continue
        end


    end
  
end




function [consecutive_ones, starting_indices] = analyze_consecutive_ones(binary_list)
    consecutive_ones = [];
    starting_indices = [];
    
    in_sequence = false;
    count = 0;
    start_idx = 0;
    
    for i = 1:length(binary_list)
        if binary_list(i) == 1
            if ~in_sequence
                % New sequence of ones starts
                in_sequence = true;
                start_idx = i;
                count = 1;
            else
                % Continue the current sequence
                count = count + 1;
            end
        else
            if in_sequence
                % End of a sequence, store results
                consecutive_ones = [consecutive_ones, count];
                starting_indices = [starting_indices, start_idx];
                in_sequence = false;
            end
        end
    end

    % Handle case where the sequence ends at the last element
    if in_sequence
        consecutive_ones = [consecutive_ones, count];
        starting_indices = [starting_indices, start_idx];
    end
end

