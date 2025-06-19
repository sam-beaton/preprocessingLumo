function prepRunAll()

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

diary(fullfile(pwd,'imageReconPreProc_29May.txt'));

clear; close all;

%% Add relevant toolboxes to current path
% Underneath parameter settings for ease of access to change
addpath(genpath('/Users/sambe/Documents/MATLAB/Toolboxes/Homer2'))
addpath(genpath('/Users/sambe/Documents/MATLAB/Toolboxes/qt-nirs'))
addpath(genpath('/Users/sambe/Documents/MATLAB/Toolboxes/DOT-HUB_toolbox'))
addpath(genpath('/Users/sambe/Documents/GitHubRepositories/preprocessingLumo'))

%% =================== Variables/arguments ======================
%initialise parameters variable
params = struct();

% Data locations
% directory with original .nirs data files:
params.dataLoc = '/Volumes/Extreme SSD/dot/nirs';
% directory where processed files will be saved, in a new sub-directory:
params.saveLoc = '/Volumes/Extreme SSD/dot/derivatives'; 


% Data information
timepoints = {'01mo', '06mo', '12mo'}; %'01mo', '06mo', '12mo'
params.task = 'hand'; %

% Preprocessing parameters
params.preprocDirName = 'preproc-imageRecon'; % used to create directory and name files
% params.regrSS = 1; % default = 0
params.lpf = 0.25;
params.motionReject = 1;
    
% add more as necessary: see preprocessLumo.m for more options

%% ======================= Run processing =========================

% Start a parallel pool (specify number of workers)
parpool(length(timepoints));

parfor iTime = 1:length(timepoints)
%for iTime = 1:length(timepoints)

    % Create a local copy of params for each worker
    paramsLocal = params;
    paramsLocal.timepoint = timepoints{iTime};
    
    % run preprocessing
    prepTools.preprocessLumo(paramsLocal);

end

% Shut down the parallel pool
delete(gcp('nocreate'));

fprintf("COMPLETE \n")

diary off;

end