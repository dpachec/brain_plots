function transformed_coords = apply_transformation(coords, xfm)
    % APPLY_TRANSFORMATION Applies a 4x4 transformation matrix to a list of 3D coordinates
    %
    % Parameters:
    %   coords (n x 3 matrix): List of 3D electrode coordinates (x, y, z)
    %   xfm (4x4 matrix): The affine transformation matrix
    %
    % Returns:
    %   transformed_coords (n x 3 matrix): List of transformed 3D coordinates
    
    % Convert the coordinates to homogeneous form (n x 4 matrix with 1s in the last column)
    n = size(coords, 1);
    homogeneous_coords = [coords, ones(n, 1)]; % Adds a column of 1s
    
    % Apply the transformation matrix
    transformed_homogeneous_coords = (xfm * homogeneous_coords')'; % Transpose for matrix multiplication
    
    % Convert back to regular 3D coordinates by removing the homogeneous component
    transformed_coords = transformed_homogeneous_coords(:, 1:3);
end
