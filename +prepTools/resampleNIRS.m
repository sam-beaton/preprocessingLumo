function [nirs, fsNew, ntNew] = resampleNIRS(nirs, fsOld, fsNew)
%
% resampleNIRS
%
% Resamples NIRS data to a target sampling frequency.
% nirs.dod is assumed to contain optical density data;
% If nirs.dod contains light intensity data, will not 
% function as intended due to likelihood of negative 
% values produced by FIR filter during 'resample' call.
%
% Updates:
%   - nirs.dod (resampled)
%   - nirs.t (recomputed)
%   - nirs.s (event timings preserved)
%
% SLB 25/03/26
%
% -------------------------------------------------------------------------

    % --- Check if resampling is needed ---
    if abs(fsOld - fsNew) < 1e-6
        fsNew = fsOld;
        return
    end
    
    fprintf('Resampling from %.3f Hz to %.3f Hz ... ', fsOld, fsNew);
    
    % --- Rational approximation of frequency ratio ---
    [nT, nCh] = size(nirs.dod);
    [p, q]    = rat(fsNew / fsOld, 1e-6);
    
    % --- Resample dod ---
    % Preallocate from actual output length of first channel
    resTemp = resample(nirs.dod(:, 1), p, q);
    ntNew   = length(resTemp);
    dodNew  = zeros(ntNew, nCh);
    dodNew(:, 1) = resTemp;
    
    for ch = 2:nCh
        dodNew(:, ch) = resample(nirs.dod(:, ch), p, q);
    end
    
    nirs.dod = dodNew;
    nirs.t   = (0:ntNew-1)' / fsNew;
    
    % --- Remap stimulus matrix (s) ---
    if isfield(nirs, 's') && ~isempty(nirs.s)
        [eventIdx, stimIdx] = find(nirs.s);
        eventTimes  = (eventIdx - 1) / fsOld;
        newEventIdx = max(1, min(ntNew, round(eventTimes * fsNew) + 1));
        nStim       = size(nirs.s, 2);
        sNew        = zeros(ntNew, nStim);
        for k = 1:length(newEventIdx)
            sNew(newEventIdx(k), stimIdx(k)) = 1;
        end
        nirs.s = sNew;
    end

    % --- store old fs for downstream motion correction ---
    nirs.fsOrig = fsOld;

    fprintf('complete.\n');

end