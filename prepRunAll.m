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

%number of parallel processes to use i.e. number of files processed at once
numWorkers = 8;

% Data locations
% directory with original .nirs data files:
params.dataLoc = '/Volumes/Extreme SSD/dot/handMethodsRaw';
% directory where processed files will be saved, in a new sub-directory:
params.saveLoc = '/Volumes/Extreme SSD/dot/derivatives'; 


% Data information
timepoints = {'06mo', '12mo'};%{'01mo', '06mo', '12mo'}; %'01mo', '06mo', '12mo'
params.task = 'hand'; %

% Preprocessing parameters
params.preprocDirName = 'preproc'; % used to create directory and name files
% params.regrSS = 1; % default = 0
params.lpf = 0.25;
% params.motionReject = 0; % default = 1
params.targetFS = 10; %required sample rate - some sampled at 12.5Hz
    
% add more as necessary: see preprocessLumo.m for more options


%% ======================= Run processing =========================

% Start a parallel pool (specify number of workers)
pool = parpool(numWorkers);

% add required toolboxes, files etc to each parallel worker
pctRunOnAll addpath(genpath('/Users/sambe/Documents/GitHubRepositories/preprocessingLumo'))
pctRunOnAll addpath(genpath('/Users/sambe/Documents/MATLAB/Toolboxes/Homer2'))
pctRunOnAll addpath(genpath('/Users/sambe/Documents/MATLAB/Toolboxes/qt-nirs'))
pctRunOnAll addpath(genpath('/Users/sambe/Documents/MATLAB/Toolboxes/DOT-HUB_toolbox'))
% addAttachedFiles(pool, { ...
%     '/Users/sambe/Documents/GitHubRepositories/preprocessingLumo/+prepTools/parsave.m', ...
%     '/Users/sambe/Documents/GitHubRepositories/preprocessingLumo/+prepTools/preprocessLumo.m' ...
% });

%parfor iTime = 1:length(timepoints)
for iTime = 1:length(timepoints)

    % Create a local copy of params for each worker
    paramsLocal = params;
    paramsLocal.timepoint = timepoints{iTime};

    % Create diary
    diaryOutDir = fullfile(params.saveLoc, 'preprocDiary'); 
    if ~exist(diaryOutDir, 'dir')
        mkdir(diaryOutDir);
    end
    todayStr = datestr(now, 'yyyy-mm-dd_HH-MM-SS'); 
    diaryFile = fullfile(diaryOutDir, ['diary_' num2str(paramsLocal.timepoint) '_' todayStr '.txt']);
    %diary(diaryFile);
    disp(['Diary started: ' diaryFile]);
    
    % run preprocessing
    prepTools.preprocessLumo(paramsLocal);
end

% Shut down the parallel pool
delete(gcp('nocreate'));

fprintf("COMPLETE \n")

diary off;

end