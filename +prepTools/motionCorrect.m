function nirs = motionCorrect(nirs, params)

    % Corrects motion artefacts in the .nirs file using spline
    % interpolation and wavelet denoising, as described in Di Lorenzo et al
    % (2019) and Frijia et al. (2021)

    % Motion detection
    [nirs.tInc , nirs.tIncCh] = hmrMotionArtifactByChannel(nirs.d, nirs.fsOrig, nirs.SD3D, [], params.tMotion, params.tMask, params.STDEVthresh, params.AMPthresh);
    
    % Resample motion masks to match nirs.dod at targetFS
    [nirs.tInc, nirs.tIncCh] = prepTools.resampleMotionMasks(nirs.tInc, nirs.tIncCh, nirs.fsOrig, params.targetFS, params.ntNew);
    
    % Motion correction: spline
    nirs.dod = hmrMotionCorrectSpline(nirs.dod, nirs.t, nirs.SD, nirs.tIncCh, params.pSpline);
    
    % Motion correction: Wavelet 
    nirs.dod = prepTools.adaptedHmrMotionCorrectWavelet(nirs.dod, nirs.SD, params.iqrWave);

end