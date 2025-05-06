function [nirs] = pruneChannels(nirs, params)

% Master function for pruning low-quality channels from the NIRS data. 
% Detects motion artifacts, applies initial channel pruning using Homer, 
% then either applies QT-NIRS or coefficient of variation (CV) pruning 
% methods based on the specified parameters.

    % Initialise windowInfo structure
    windowInfo = struct();
    
    % Detect motion artifacts using amp and std thresholds (by channel)
    [nirs.SD.tInc, nirs.SD.tIncCh] = hmrMotionArtifactByChannel(nirs.d, nirs.t, nirs.SD, [], params.tMotion, params.tMask, params.STDEVthresh, params.AMPthresh);

    % Prune channels using Homer prior to QT-NIRS
    nirs.SD = enPruneChannels(nirs.d, nirs.SD, nirs.SD.tInc, params.dRange, params.SNRthresh, params.SDrange, 0);

    % Get number of channels (both chromophores)
    numChan = length(nirs.SD.MeasListAct)/2;
    
    % QT-NIRS pruning
    [nirs, ~] = prepTools.pruneWithQT(nirs, params, numChan);

end