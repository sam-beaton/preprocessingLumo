%% prepRunAll
% Script which calls preprocessLumo (saves having to repeat for every age)
% whilst saving the .nirs files
%
% Designed for LUMO files in BIDS format
%
% To do:
% Find a way to softcode number of max channels so that it is equal to 
% number in larger arrays, without having to load every file.
%
% SLB 17/1/24

clear; close all;

%% Add relevant toolboxes to current path
% Underneath parameter settings for ease of access to change
addpath(genpath('/Users/sambe/Documents/MATLAB/Toolboxes/Homer2'))
addpath(genpath('/Users/sambe/Documents/MATLAB/Toolboxes/qt-nirs'))
addpath(genpath('/Users/sambe/Documents/MATLAB/Toolboxes/DOT-HUB_toolbox'))
addpath(genpath('/Users/sambe/Documents/GitHubRepositories/preprocessingLumo'))

%initialise parameters variable
params = struct();

%Change cohort variables here (won't change for entire run of script)
params.dataRawLoc = '/Users/sambe/indigoChecks/fNIRS'; % Main directory with original .nirs data files
params.dataOutLoc = '/Users/sambe/Data/prep/indigo'; %parent directory for saved pruned files

%%% ============ Cohort variables/arguments =================
tasks = {'hand'}; % e.g. 'hand', 'social'
timepoints = {'01mo', '06mo', '12mo'}; %'01mo', '06mo', '12mo'

%%% ======= Processing variables/arguments ============


% Start a parallel pool (specify number of workers)
%parpool(6);

for iTask = 1:length(tasks)

    params.task = tasks{iTask};
    
    for iTime = 1:length(timepoints)

        % Create a local copy of params for each worker
        paramsLocal = params;
        params.timepoint = timepoints{iTime};

        
    end
    % Shut down the parallel pool
    delete(gcp('nocreate'));
end

fprintf("COMPLETE \n")