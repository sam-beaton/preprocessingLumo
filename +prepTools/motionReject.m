function nirs = motionReject(nirs, params)

    % Rejects trials with persistent noise - designed to be run *after*
    % motion correction using prepTools.motionCorrect
    
    % use (back-converted) light intensity data for motion detection
    dTemp = prepTools.od2Intensity(nirs.dod, mean(abs(nirs.d),1));

    % Motion detection (for trial rejection)
    [tInc, tIncCh] = hmrMotionArtifactByChannel(dTemp, nirs.t, nirs.SD3D, [], params.tMotion, params.tMask, params.STDEVthresh, params.AMPthresh);
    
    % -------------- Trial rejection -----------------
    % keep nirs.s as is, or most of data lost during neuroDOT's conversion
    [~, ~, nirs.sCh] = prepTools.adaptedEnStimRejection(nirs.t, nirs.s, tInc, [], params.tRangeRej, tIncCh);

    % Update SD3D with Excluded time periods from various detection points
    nirs.SD3D.tInc=tInc;
    nirs.SD3D.tIncCh=tIncCh;
    nirs.SD.tInc=tInc;
    nirs.SD.tIncCh=tIncCh;
    
    %Force MeasListAct to be the same across wavelengths
    nirs.SD3D = DOTHUB_balanceMeasListAct(nirs.SD3D);
    nirs.SD = DOTHUB_balanceMeasListAct(nirs.SD);

end

% % Uncomment to plot detected motion for verification
% figure;
% imagesc(tIncCh);
% colormap([1 1 1; 0 0 0]); % White for 0, Black for 1
% colorbar; % Add a colorbar for reference
% caxis([0 1]); % Ensure only two values are mapped
% axis equal tight; % Adjust axis
% title('Binary Heatmap');
% xlabel('X Axis');
% ylabel('Y Axis');