function xfm = read_talxfm(tal_path)
    % READ_TALXFM Reads the Talairach transform from a talairach.xfm file
    %
    % Parameters:
    %   subject (string): The name of the subject
    %   subjects_dir (string): The path to the FreeSurfer subjects directory
    %
    % Returns:
    %   xfm (4x4 matrix): The affine transformation matrix
    
    % Construct the path to the talairach.xfm file
    %tal_path = fullfile(subjects_dir, subject, 'mri', 'transforms', 'talairach.xfm');

    % Check if the file exists
    if ~isfile(tal_path)
        error('Talairach transform file not found at %s', tal_path);
    end

    % Initialize the transformation matrix as a 4x4 identity matrix
    xfm = eye(4);

    % Open the file and read it line by line
    fid = fopen(tal_path, 'r');
    if fid == -1
        error('Could not open the file %s', tal_path);
    end

    try
        foundTransform = false;
        while ~feof(fid)
            line = fgetl(fid);
            if contains(line, 'Linear_Transform')
                foundTransform = true; % Mark that we found the transform section
                for i = 1:3
                    line = fgetl(fid);
                    values = sscanf(line, '%f %f %f %f'); % Extract 4 floats
                    if numel(values) ~= 4
                        error('Error: Transformation matrix row does not contain exactly 4 values in %s', tal_path);
                    end
                    xfm(i, 1:4) = values'; % Assign to the transformation matrix (3 rotation, 1 translation)
                end
                break;
            end
        end
        if ~foundTransform
            error('Error: Could not find "Linear_Transform" section in %s', tal_path);
        end
    catch ME
        fclose(fid);
        rethrow(ME); % Rethrow the original error for clarity
    end

    % Close the file
    fclose(fid);
end
