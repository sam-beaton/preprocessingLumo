% Root path and destination path
rootPath = '/Users/sambe/dot/nirs';
destPath = '/Users/sambe/dot/derivatives';

% Ensure destination directory exists
if ~exist(destPath, 'dir')
    mkdir(destPath);
end

% Create data_quality_checks directory in destination
dataQualityDestPath = fullfile(destPath, 'data_quality_checks');
if ~exist(dataQualityDestPath, 'dir')
    mkdir(dataQualityDestPath);
end

% Keep track of directories to delete
directoriesToDelete = {};

% Find all 'derivatives' directories
d = dir(fullfile(rootPath, '**', 'derivatives'));
% Filter out . and .. directories
d = d(~ismember({d.name}, {'.', '..', '.DS_Store'}));

% Process each derivatives directory
for i = 1:length(d)
    % Get the full path to the current derivatives directory
    currentDir = fullfile(d(i).folder, d(i).name);
    
    % Look for subject and session within the path
    pathParts = strsplit(currentDir, filesep);
    subjIdx = find(contains(pathParts, 'sub-'), 1);
    sessIdx = find(contains(pathParts, 'ses-'), 1);
    
    % Ensure we found subject and session
    if ~isempty(subjIdx) && ~isempty(sessIdx)
        % Get subject and session identifiers
        subjectID = pathParts{subjIdx};
        sessionID = pathParts{sessIdx};
        
        % Look for data_quality_checks directory
        dataQualityDir = currentDir;
        
        % Find task-all directories
        taskAllDirs = dir(fullfile(dataQualityDir, '**', 'task-all'));
        taskAllDirs = taskAllDirs(~ismember({taskAllDirs.name}, {'.', '..', '.DS_Store'}));
        
        % Process each task-all directory
        for j = 1:length(taskAllDirs)
            % Full path to this task-all directory
            fullTaskAllPath = fullfile(taskAllDirs(j).folder, taskAllDirs(j).name);
            allPathParts = strsplit(fullTaskAllPath, filesep);
            runIdx = find(contains(allPathParts, 'run-'), 1);
            runID = allPathParts{runIdx};

            % Create destination path
            destSubjectPath = fullfile(dataQualityDestPath, subjectID);
            destSessionPath = fullfile(destSubjectPath, sessionID);
            destTaskAllPath = fullfile(destSessionPath, 'task-all');
            destRunPath = fullfile(destTaskAllPath, runID);
            
            % Create directories
            mkdir(destSessionPath);
            
            % Copy contents
            copyfile(fullTaskAllPath, destRunPath);
            
            fprintf('Copied %s to %s\n', fullTaskAllPath, destTaskAllPath);
        end

        delDir = fileparts(currentDir);
        directoriesToDelete{end+1} = delDir;

    end
end

% Delete source directories
disp('Deleting source directories...');
for i = 1:length(directoriesToDelete)
    try
        % Attempt to remove the entire subject directory
        rmdir(directoriesToDelete{i}, 's');
        fprintf('Deleted directory: %s\n', directoriesToDelete{i});
    catch ME
        fprintf('Error deleting directory %s: %s\n', directoriesToDelete{i}, ME.message);
    end
end

disp('Data quality checks merged and source directories removed successfully.');