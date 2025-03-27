function nirs = motionCorrect(nirs, params)

    % Corrects motion artefacts in the .nirs file using spline
    % interpolation and wavelet denoising, as described in Di Lorenzo et al
    % (2019) and Frijia et al. (2021)

    % Motion detection
    [ ~ , tIncCh] = hmrMotionArtifactByChannel(nirs.d, nirs.t, nirs.SD3D, [], params.tMotion, params.tMask, params.STDEVthresh, params.AMPthresh);

    % Motion correction: spline
    nirs.dod = hmrMotionCorrectSpline(nirs.dod, nirs.t, nirs.SD, tIncCh, params.pSpline);

end