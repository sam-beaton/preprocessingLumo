function [nirs, fsNew] = resampleNIRS(nirs, fsOld, fsNew)
%
% resampleNIRS
%
% Resamples NIRS data to a target sampling frequency.
% Updates:
%   - nirs.d (resampled)
%   - nirs.t (recomputed)
%   - nirs.s (event timings preserved)
%
% -------------------------------------------------------------------------

    % --- Check if resampling is needed ---
    if abs(fsOld - fsNew) < 1e-6
        fsNew = fsOld;
        return
    end

    fprintf('Resampling from %.3f Hz to %.3f Hz ... ', fsOld, fsNew);    

    % =========================
    % 1. RESAMPLE DATA (d)
    % =========================
    % d is [time x channels]
    [p, q] = rat(fsNew / fsOld);
    [nT, nCh] = size(nirs.d);
    dNew = zeros(ceil(nT * p / q), nCh);
    for ch = 1:nCh
        dNew(:,ch) = resample(nirs.d(:,ch), p, q);
    end
    nirs.d = dNew;

    % =========================
    % 2. RECOMPUTE TIME (t)

    ntNew = size(nirs.d, 1);
    nirs.t = (0:ntNew-1)' / fsNew;

    % =========================
    % 3. FIX STIMULUS (s)
    if isfield(nirs, 's') && ~isempty(nirs.s)

        % Find original events
        [eventIDx, stimIDx] = find(nirs.s);

        % Convert to time (seconds)
        eventTimes = (eventIDx - 1) / fsOld;

        % Map to new indices
        newEventIDx = max(1, min(ntNew, round(eventTimes * fsNew) + 1));

        % Rebuild stimulus matrix
        nStim = size(nirs.s, 2);
        sNew = zeros(ntNew, nStim);

        for k = 1:length(newEventIDx)
            i = newEventIDx(k);
            j = stimIDx(k);

            if i >= 1 && i <= ntNew
                sNew(i, j) = 1;
            end
        end

        nirs.s = sNew;
    end

    fprintf('complete.\n');

end