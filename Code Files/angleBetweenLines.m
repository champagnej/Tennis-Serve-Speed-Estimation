function angle = angleBetweenLines(start1, end1, start2, end2)
    % Calculate the direction vectors for each line
    vec1 = end1 - start1;
    vec2 = end2 - start2;
    
    % Calculate the dot product of the vectors
    dotProd = dot(vec1, vec2);
    
    % Calculate the magnitudes of each vector
    magVec1 = norm(vec1);
    magVec2 = norm(vec2);
    
    % Calculate the angle in radians
    angleRad = acos(dotProd / (magVec1 * magVec2));
    
    % Convert the angle to degrees
    angle = rad2deg(angleRad);
end