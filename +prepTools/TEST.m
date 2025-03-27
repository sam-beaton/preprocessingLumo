filename = 'sub-001d_ses-01_task-hand_run-01.nirs';

% Split the filename by underscores
splits = strsplit(filename, '_');

% Initialize struct to store parts
parts = struct();

% Process each split part
for i = 1:length(splits)
    % Split each part by hyphen
    subSplits = strsplit(splits{i}, '-');
    
    % Only process parts with a hyphen
    if length(subSplits) > 1
        % Convert to lowercase to ensure consistent parsing
        key = lower(subSplits{1});
        value = subSplits{2};
        
        % Remove file extension if it's the last part
        if i == length(splits)
            % Split off the file extension
            extSplits = strsplit(value, '.');
            value = extSplits{1};
        end
        
        % Store in struct
        parts.(key) = value;
    end
end

parts