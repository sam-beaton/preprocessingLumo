% d = sbDotOD2Intensity( dod )
%
% Converts optical density data to intensity/attenuation data
% Is effectively the inverse of hmrIntensity2OD
%
% INPUT
% dod - the change in optical density
% dm - (optional) mean of intensity/attenuation data
%
% OUTPUT
% d - intensity data (#time points x #data channels

function d = od2Intensity(dod, dm)

% Calculate the number of time points
nTpts = size(dod, 1);

if exist('dm', 'var')
    % Calculate d
    d = (ones(nTpts, 1) * dm) .* exp(-dod);
else
    % Estimate an initial dm
    dm_est = ones(nTpts, 1); % Starting with a vector of ones
    
    % Iteratively estimate dm
    tolerance = 1e-6;
    max_iter = 1000;
    for iter = 1:max_iter
        d_est = dm_est .* exp(-dod);
        dm_new = mean(d_est, 1);
        if norm(dm_new - dm_est) < tolerance
            break;
        end
        dm_est = dm_new;
    end
    
    % Final estimation of d using the estimated dm
    d = dm_est .* exp(-dod);
end