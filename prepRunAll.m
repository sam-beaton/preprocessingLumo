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

%% =================== Variables/arguments ======================
%initialise parameters variable
params = struct();

% Data location
params.dataLoc = '/Users/sambe/dot/nirs'; % Main directory with original .nirs data files

% Data information
timepoints = {'01mo', '06mo', '12mo'}; %'01mo', '06mo', '12mo'
params.task = 'hand';

% remove SSR for dealing with physiological noise
%params.regrSS = 0;

% add more as necessary: see preprocessLumo.m for more options

%% ======================= Run processing =========================

% Start a parallel pool (specify number of workers)
%parpool(length(timepoints));
    
for iTime = 1:length(timepoints)

    % Create a local copy of params for each worker
    paramsLocal = params;
    paramsLocal.timepoint = timepoints{iTime};

    prepTools.preprocessLumo(paramsLocal);

end

% Shut down the parallel pool
delete(gcp('nocreate'));

fprintf("COMPLETE \n")