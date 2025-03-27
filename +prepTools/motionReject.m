function nirs = motionReject(nirs, params)

    % Rejects trials with persistent noise - designed to be run *after*
    % motion correction using prepTools.motionCorrect

    % Motion detection (for trial rejection)
    [tInc, tIncCh] = hmrMotionArtifactByChannel(nirs.dod, nirs.t, nirs.SD3D, [], params.tMotion, params.tMask, params.STDEVthresh, params.AMPthresh);
    
    %  -------------- Trial rejection -----------------
    [nirs.s, ~] = enStimRejection(nirs.t, nirs.s, tInc, [], params.tRangeRej);

    % Update SD3D with Excluded time periods from various detection points
    nirs.SD3D.tInc=tInc;
    nirs.SD3D.tIncCh=tIncCh;
    nirs.SD.tInc=tInc;
    nirs.SD.tIncCh=tIncCh;
    
    %Force MeasListAct to be the same across wavelengths
    nirs.SD3D = DOTHUB_balanceMeasListAct(nirs.SD3D);
    nirs.SD = DOTHUB_balanceMeasListAct(nirs.SD);

end