function params = validateInputs(params)

%% Checks required inputs: data location,
% timepoint and task

if ~isfield(params, 'dataLoc')
    error("Must provide valid data directory.  See 'help' for details")
end

if ~isfield(params, 'task')
    error("Must provide valid task.  See 'help' for details")
end

if ~isfield(params, 'timepoint')
    error("Must provide valid timepoint.  See 'help' for details")
end


%% DEFAULTS:

% Saturated/low signal channel removal
if ~isfield(params, 'dRange')
    params.dRange = [1e-03 1e+07]; % Di Lorenzo et al. 2019
end
if ~isfield(params, 'snrThresh')
    params.SNRthresh = 0; % Di Lorenzo et al. 2019
end
if ~isfield(params, 'sdRange')
    params.SDrange = [0 60]; % Frijia et al. 2021
end

%% Motion detection parameters
if ~isfield(params, 'tMotion')
    params.tMotion = 1; % Di Lorenzo et al. 2019
end
if ~isfield(params, 'tMarkPrune')
    params.tMaskPrune = 0; % Want to only consider the motion itself WHEN PRUNING
end
if ~isfield(params, 'tMask')
    params.tMask = 1; % want a buffer of 1s normally (Di Lorenzo et al. 2019)
end
if ~isfield(params, 'STDEVthresh')
    params.STDEVthresh = 15; % Di Lorenzo et al. 2019
end
if ~isfield(params, 'AMPthresh')
    params.AMPthresh = 0.4; % Di Lorenzo et al. 2019
end

%% Channel pruning 
if ~isfield(params, 'sciThreshold')
    switch params.timepoint
        case '01mo'
            params.sciThreshold = 0.7; %standard for adults - Pollonini et al 2016
        case '06mo'
            params.sciThreshold = 0.7; %standard for adults - Pollonini et al 2016
        case '12mo'
            params.sciThreshold = 0.7; %standard for adults - Pollonini et al 2016
    end
end
if ~isfield(params, 'pspThreshold')
    switch params.timepoint
        case '01mo'
            params.pspThreshold = 0.1; %standard for adults - Pollonini et al 2016
        case '06mo'
            params.pspThreshold = 0.1; %standard for adults - Pollonini et al 2016
        case '12mo'
            params.pspThreshold = 0.1; %standard for adults - Pollonini et al 2016
    end
end

%window length, for QT-NIRS and motion-affected sample exclusion
if ~isfield(params, 'windowSec')
    params.windowSec = 3; 
end
% minimum number of motion windows before exclusion from pruning
if ~isfield(params, 'badWindowThresh')
    params.badWindowThresh = 3;
end

% heartrate bandpass
if ~isfield(params, 'bpFmin')
    params.bpFmin = 1.2; 
end
if ~isfield(params, 'bpFmax')
    params.bpFmax = 3.2; %Minigawa et al. 2023
end

%misc. parameters
if ~isfield(params, 'qualityThreshold')
    params.qualityThreshold = 0.75;
end
if ~isfield(params, 'windowOverlap')
    params.windowOverlap = 0; %Pollonini et al 2016
end
if ~isfield(params, 'guiFlag')
    params.guiFlag = 0; %change to see the graphics containing qtnirs 'quality' for each channel
end

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
