function preprocessLumoStrictLPF(params)
%
% preprocessLumo
%
% Preprocesses HD-DOT data using pre-selected methods and user-defined
% parameters.
% Assumes data is stored in BIDS format
% 
% -------------------------------------------------------------------------
%
% Steps:
%
% [processing steps here]
% 
% -------------------------------------------------------------------------
%
% Arguments:        contained in the 'params' variable 
%     
% [input parameters here]
%
% dataRawLoc:       parent folder containing raw .nirs files (in BIDS 
%                   format) to be processed
%
% dataOutLoc        parent folder to store processed files (will be stored
%                   BIDS format)
%
% timepoint:        defines age of participants; must include 'mo'
%                   INDiGO:
%                   '1mo', '6mo', '12mo'
%                   
% task:             name of task 
%                   INDiGO: 'hand', 'fc1' or 'fc2'
%
% -------------------------------------------------------------------------
% Arguments:            define the pipeline methods
% (optional)            ----- For Global pipeline set all to 1-----
%
% standardQT:           1/True utilises parameter values from Pollonini et
%                       al (2016) for QT;
%                       otherwise, values should be specified by user
%
% sciThreshold:         Value for SCI threshold in QT-NIRS to be specified
%                       by user
%
% pspThreshold:         Value for PSP threshold in QT-NIRS to be specified
%                       by user
%
% motionDetectHomer:    1/True selects Homer's motion artifact detection; 
%                       otherwise, a Sobel filter is used for motion
%                       artifact detection
%
% strictSobel:          1/True opts to use the author defined IQR coefft. 
%                       value of 1.5 from Jahani et al. (2018)
%                       otherwise, an IQR coefficient of 2 (more lenient 
%                       for e.g infant participants) is used
%
% filterBand:           1 elects to use both a low *AND HIGH* pass filter;
%                       otherwise, linear detrending is used (during block 
%                       averaging) in place of the high pass filter
%
% regressShortSig:      1 ensures pipeline will utilise short separation
%                       regression (SSR) to remove physiological noise;
%                       otherwise, no SSR is employed
%
% shortSigMethod:       2 uses the average of short channels closest to the
%                       source & detector of the long channel for SSR;
%                       1 uses the global average of short channels;
%                       otherwise, the nearest short channel is used
%
% -------------------------------------------------------------------------
%
% Outputs:              preprocessed files are saved in the 'derivatives'
%                       folder of the parent directory
%
% SLB 17/1/2024
%
% Edited 25/3/25 to convert to modular form


    %% Input processing. Check input arguments and assign where necessary
    params = prepTools.validateInputs(params);
    params.lpf = 0.2;

    %% Create output directory if necessary
    preprocDirName = 'preproc-02LPF'; % defined as variable as used later
    preprocDir = fullfile(params.saveLoc, preprocDirName);
    if ~isfolder(preprocDir)
        mkdir(preprocDir);
    end

    %% Change path and search for task files 
    % change directory 
    cd(params.dataLoc);
    % Recursively get all .nirs fiels with correct task and age
    timepointNum = str2double(params.timepoint(1:2)); % Converts '01' -> 1, '48' -> 48
    timepointNum = sprintf('%02d', timepointNum); % Ensures zero-padded format
    fileList = dir(fullfile(params.dataLoc, '**', sprintf('*ses-%s*task-%s*.nirs', timepointNum, params.task)));
    fileList = fileList(arrayfun(@(f) ~startsWith(f.name, '.'), fileList));

    % Extract file paths directly
    matchingFiles = fullfile({fileList.folder}, {fileList.name});

    % Run Preprocessing
    for nsub = 1:length(matchingFiles)

        tic

        % ------- Load data and initial checks/conversions -------

        % (just so cmd window not blank as removed wavelet dwtmode message)
        partName = fileList(nsub).name;
        fprintf(strcat("Preprocessing age ", params.timepoint, ", participant ", num2str(nsub), " - ", partName(5:8), " - run ", partName(end-6:end-5),  "\n\n"));

        % Load subject data
        [nirs, ~] = prepTools.loadSubjectData(matchingFiles{nsub});

        % double-check on NaNs in nirs.d, but these should have been
        % removed during task cutting
        if ~length(find(isnan(nirs.d))) == 0
            % print message notifying of NaNs
            nanErrorMsg = strcat("File ", partName, " could not be processed: data contains NaNs \n\n");
            fprintf(nanErrorMsg);
            continue
        end

        % Calculate DPF for age
        params.dpf = prepTools.calculateDPF(str2double(timepointNum), nirs, 1);

        %calculate the sampling frequency
        fs = 1 / mean(diff(nirs.t)); 
    
        % get (cap specific) number of channels in array
        if ~exist('nirs.SD.MeasListAct', 'var')
            nirs.SD.MeasListAct = nirs.SD.MeasList(:,3);
        end
        numChansBothChroms = length(nirs.SD.MeasListAct);

        % ------- Channel pruning -------
        %plot(nirs.d)
        fprintf("Pruning channels ... ");
        % Detect motion artifacts and prune channels
        nirs = prepTools.pruneChannels(nirs, params);
        %fprintf("NEED TO ADD CHANNEL PRUNING BACK INTO PIPELINE ...");
        fprintf("complete. \n");

        % Plotting
        %figure; plot(nirs.d)
        %nirs.dOrig = nirs.d; % for later plotting comparison after back-conversion from dc

        % ------- Convert to OD ------
        fprintf("Converting to OD data ... ");
        % Convert Intensity into Optical Density 
        nirs.dod = hmrIntensity2OD(nirs.d);
        fprintf("complete. \n");

        % Plotting
        %figure; plot(nirs.dod)
        %nirs.dodOrig = nirs.dod; % for later plotting comparison after back-conversion from dc

        % ------- Motion Correction -------
        fprintf("Correcting motion ... ");
        nirs = prepTools.motionCorrect(nirs, params);
        %for quick testing:
        %nirs = prepTools.motionCorrectNoWave(nirs, params); fprintf("NEED TO ADD WAVELET DENOISING BACK INTO PIPELINE ..."); 
        fprintf("complete. \n");

        % Plotting
        %figure; plot(nirs.dod)

        % ------- Motion Rejection -------
        fprintf("Removing trials with persistent noise ... ");
        nirs = prepTools.motionReject(nirs, params);
        fprintf("complete. \n");

        % Plotting
        %figure; plot(nirs.dod)
    
        % ------- Bandpass filtering -------
        fprintf("Filtering ... ");
        % Bandpass filter
        nirs.dod = hmrBandpassFilt(nirs.dod, nirs.t, params.hpf, params.lpf);
        fprintf("complete. \n");

        % Plotting
        %figure; plot(nirs.dod)

        % ------- Convert to concentration data -------
        fprintf("Converting to Concentration data ... ");
        %note dodFilt is the output needed for non-averaged dod data if NOT
        %using SSR
        nirs.dc = hmrOD2Conc(nirs.dod, nirs.SD3D, params.dpf); 
        %nirs.dc = nirs.dc*1e6; %Homer works in Molar by default, we use uMolar
        fprintf("complete. \n");

        % Plotting
        %figure; plot(squeeze(nirs.dc(:, 1, :)))
    
        % ------- Shot signal regression -------
        if params.regrSS == 1
            fprintf("Regressing short signals ... ");
            nirs.dc = DOTHUB_hmrSSRegressionByChannel(nirs.dc, nirs.SD3D, params.rhoSD_ssThresh, params.flagSSmethod);
            fprintf("complete. \n");
        end

        % Plotting
        %figure; plot(squeeze(nirs.dc(:, 1, :))

        % ------- Block averaging -------
        fprintf("Block averaging ... ");
        [nirs.dcAvg, nirs.dcAvgStd, nirs.tHRF] = hmrBlockAvg(nirs.dc, nirs.s, nirs.t, params.tRange);
        %[nirs.dcAvg, nirs.dcAvgStd, nirs.tHRF] = sbPrePhmrBlockAvgDetrend(nirs.dc, nirs.s, nirs.t, params.tRange);
        fprintf("complete. \n");

        % Plotting
        %figure; plot(squeeze(nirs.dc(:, 1, :)))

        % ------- Variable conversion for compatibility with NeuroDOT -------
        fprintf("Converting data back to OD for reconstruction ... ");
        %Convert dc back to dod 
        nirs.dod = DOTHUB_hmrConc2OD(nirs.dc, nirs.SD3D, params.dpf);
        %Convert dod back to d for reconstruction in Neurodot
        nirs.d = prepTools.od2Intensity(nirs.dod, mean(abs(nirs.d),1));
        fprintf("complete. \n");
        
        % Plotting
%         figure; plot(nirs.dodOrig)
%         figure; plot(nirs.dod)
%         figure; plot(nirs.dOrig)
%         figure; plot(nirs.d)
%         figure; plot(squeeze(nirs.dc(:,1,:)))
%         figure; plot(squeeze(nirs.dcAvg(:,1,:,1)))

        %%% ============== CREATE LOG DATA AND SAVE =======================
        % Use original filename to define save directory and new filename
        splits = strsplit(partName, '_');
        taskSplit = strsplit(splits{3}, '-');
        nameSplit = strsplit(partName, '.');
        nirsSavePath = fullfile(preprocDir, ...
                                splits{1}, ...
                                splits{2}, ...
                                taskSplit{2});
        if ~isfolder(nirsSavePath)
            mkdir(nirsSavePath);
        end 
        nirsFilename = [nameSplit{1} '_' preprocDirName '.nirs'];

        % create log data
        ds = datestr(now,'yyyymmDDHHMMSS');
        logData(1,:) = {'Created on: '; ds};
        logData(2,:) = {'Derived from data: ', partName};
        logData(3,:) = {'Pre-processed using:', mfilename('fullpath')};
        nirs.logData = logData;
        
        % save file
        fprintf("Saving .nirs file ... ");
        save(fullfile(nirsSavePath, nirsFilename), '-struct', 'nirs');
        fprintf("complete. \n\n");

        toc
      
    end

end