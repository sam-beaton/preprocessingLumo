function params = validateInputs(params)

%% Checks required inputs: data location,
% timepoint and task

if ~isfield(params, 'dataLoc')
    error("Must provide valid data directory.  See 'help' for details")
end

if ~isfield(params, 'task')
    error("Must provide valid task.  See 'help' for details")
end

if ~isfield(params, 'task')
    error("Must provide valid timepoint.  See 'help' for details")
end


%% DEFAULTS:

% Saturated/low signal channel removal
params.dRange = [1e-03 1e+07]; % Di Lorenzo et al. 2019
params.SNRthresh = 0; % Di Lorenzo et al. 2019
params.SDrange = [0 60]; % Frijia et al. 2021

%% Motion detection parameters
params.tMotion = 1; % Di Lorenzo et al. 2019
params.tMaskPrune = 0; % Want to only consider the motion itself WHEN PRUNING
params.tMask = 1; % want a buffer of 1s normally (Di Lorenzo et al. 2019)
params.STDEVthresh = 15; % Di Lorenzo et al. 2019
params.AMPthresh = 0.4; % Di Lorenzo et al. 2019

%% Channel pruning
if ~exist('sciThreshold', 'var') && ~exist('pspThreshold', 'var')
    sciThreshold = 0.7; %standard for adults - Pollonini et al 2016
    pspThreshold = 0.1; %standard for adults - Pollonini et al 2016
end
%window length, for QT-NIRS and motion-affected sample exclusion
params.windowSec = 3; 
% minimum number of motion windows required in order to exclude from pruning
% calculations
params.badWindowThresh = 3;

if pruneQT == 1
    % QT-NIRS parameters
    % User defined:
    params.sci_threshold = sci_threshold; 
    params.psp_threshold = psp_threshold;
    % Set:
    params.bpFmin = 1.2; params.bpFmax = 3.2; %Minigawa et al. 2023
    params.windowSec = 3; %Allows for better motion detection exclusion using windows from QT-NIRS pruning
    params.windowOverlap = 0; %Pollonini et al 2016
    params.quality_threshold = 0.75; %change for infants?
else
    % Threshold of CV
    %set as decimal for percentage equivalent, not as integer value!
    params.CV = 0.08; % Frijia et al. 2020
end

params.gui_flag = 0; %change if you want to see the graphics containing qtnirs 'quality' for each channel


%% DPF for  

%% Spline denoising parameter
if ~isfield(params, 'pSpline')
    params.pSpline = 0.99; % Scholkmann et al 2010
end

%% Wavelet denoising parameter
if ~isfield(params, 'iqrWave')
    params.iqrWave = 0.8; % Molavi and Dumont 2012
end

%% Time range for block averaging and stim rejection
if ~isfield(params, 'tRange')
    params.tRange = [-4 18]; %based on fPCA work
end
if ~isfield(params, 'tRangeRej')
    params.tRangeRej = [-4 12]; % Di Lorenzo et al. 2019
end

%% High and low pass filter params
if ~isfield(params, 'tRangeRej')
    params.hpf = 0.01; % Di Lorenzo et al. 2019
end
if ~isfield(params, 'tRangeRej')
    params.lpf = 0.5; % Di Lorenzo et al. 2019
end

%% Short signal regression params
% to regress short signals or not:
if ~isfield(params, 'regrSS')
    params.regrSS = 0; % don't run if not specified
end
% if using SSR, define parameters:
if params.regrSS == 1
    params.rhoSD_ssThresh = 10;
    if isfield(params, 'ssrMethod') && params.ssrMethod == 2
        params.flagSSmethod = 4; %Avg of short channels < rhoSSD_ssThresh distance from either source or detector in long channel: Uchitel et al. (2022), Gagnon et al (2012)
    elseif isfield(params, 'ssrMethod') && params.ssrMethod == 1
        params.flagSSmethod = 2; %Avg of short channels: Uchitel et al. (2023), Sato et al (2016)
    else
        params.flagSSmethod = 0; %Nearest short channel: Emberson et al (2016); 
    end
end
