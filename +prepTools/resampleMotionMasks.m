function [tIncNew, tIncChNew] = resampleMotionMasks(tInc, tIncCh, fsOld, fsNew, ntNew)
    nT = length(tInc);
    oldIdx2new = @(i) max(1, min(ntNew, round((i - 1) * (fsNew / fsOld)) + 1));

    tIncChNew = ones(ntNew, size(tIncCh, 2));
    for i = 1:nT
        ni = oldIdx2new(i);
        tIncChNew(ni,:) = tIncChNew(ni,:) & tIncCh(i,:);
    end

    % tInc is 0 at any timepoint where any channel has motion
    tIncNew = double(all(tIncChNew, 2));
end