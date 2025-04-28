function intersectionPoints = findUsefulIntersections(lineStruct, minx, miny, maxx, maxy)
    % Initialize an empty array to store intersection points
    intersectionPoints = [];

    % Number of lines
    numLines = length(lineStruct);

    % Loop over all unique pairs of lines
    for i = 1:numLines-1
        for j = i+1:numLines
            % Extract points for the first line
            p1 = lineStruct(i).point1;
            p2 = lineStruct(i).point2;

            % Extract points for the second line
            p3 = lineStruct(j).point1;
            p4 = lineStruct(j).point2;

            % Compute intersection point
            [x_intersect, y_intersect, isIntersecting] = computeIntersection(p1, p2, p3, p4);

            % Check if lines are not parallel and intersection exists
            if isIntersecting
                % Check if the intersection point lies within the bounding box
                if x_intersect >= minx && x_intersect <= maxx && y_intersect >= miny && y_intersect <= maxy

                    % Check if the angle of 2 lines is large enough
                    angle = angleBetweenLines(p1,p2,p3,p4);
                    if (angle > 45 && angle < 135)
                        % Append the intersection point
                        if ~ismember(x_intersect,intersectionPoints)
                            intersectionPoints = [intersectionPoints; x_intersect, y_intersect];
                        end
                    end
                end
            end
        end
    end
end



function [x, y, isIntersecting] = computeIntersection(p1, p2, p3, p4)
    % Compute the intersection point of two lines defined by points p1, p2 and p3, p4
    % Returns x and y coordinates and a flag indicating if the lines intersect

    % Line 1 represented as a1x + b1y = c1
    a1 = p2(2) - p1(2);
    b1 = p1(1) - p2(1);
    c1 = a1 * p1(1) + b1 * p1(2);

    % Line 2 represented as a2x + b2y = c2
    a2 = p4(2) - p3(2);
    b2 = p3(1) - p4(1);
    c2 = a2 * p3(1) + b2 * p3(2);

    % Compute the determinant
    determinant = a1 * b2 - a2 * b1;

    if determinant == 0
        % Lines are parallel or coincident
        x = NaN;
        y = NaN;
        isIntersecting = false;
    else
        % Lines intersect
        x = (b2 * c1 - b1 * c2) / determinant;
        y = (a1 * c2 - a2 * c1) / determinant;
        isIntersecting = true;
    end
end
