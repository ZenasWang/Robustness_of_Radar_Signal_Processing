function [targetList, range_doppler, range_ux, range_uy] = new_signalProcessing( rawData, radarParameter )
% signal Processing of the Radar Signal to get the
% output as a dected target list with estimated range, velocity and DOA

% - rawData         := the simulated signal with noise
% - radarParameter  := defined radar parameters
% - targetList      := estimated tagets information [range, speed, ux, uy]
% - range_ux        := matix of range_ux_figure
% - range_uy        := matix of range_uy_figure

% define cfar parameters
numTrainingCells = 40;
numGuardCells = 4;
probabilityFalseAlarm = 1e-5;
zeroPadingFactor = 3;

% Window
% windowData = repmat(chebwin(size(rawData, 1), 30) * chebwin(size(rawData, 2), 30)' , 1, 1, size(rawData, 3));
% windowData = repmat(chebwin(size(rawData,1)),1, size(rawData,2),size(rawData,3));
% radarData = rawData.* windowData;
radarData = rawData;

% 2D FFT
arrayResponse_3D = fft2(radarData, zeroPadingFactor * size(radarData, 1), ...
                        zeroPadingFactor * size(radarData, 2));
arrayResponse_3D = fftshift(arrayResponse_3D, 2);
range_doppler = squeeze(sum(abs(arrayResponse_3D).^2, 3));

% detect targets in range direction
rangeSpec = sum(abs(arrayResponse_3D).^2, 2);

% sum of all range spectra of the antennas
rangeSpec_sum = sum(rangeSpec, 3); % N_sample x 1

% detect targets range

% set the detector parameter, os-cfar detector
range_detector = phased.CFARDetector('Method', 'OS', 'NumTrainingCells', numTrainingCells,...
    'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
      'Rank', 15);

% get the binary Mask after cfar
CFAR_binaryMask = range_detector(rangeSpec_sum, 1:numel(rangeSpec_sum));

% cluster to find the different target
rangeSpecMaxPos = clusterCFARMask(rangeSpec_sum, CFAR_binaryMask);

% peak detection and interpolation to got the real maxIndes
peakPos = peakInterp(rangeSpecMaxPos, rangeSpec_sum);

% map to real ranges
rangeDetections = (zeroPadingFactor * radarParameter.N_sample - peakPos + 1)/zeroPadingFactor ...
        * radarParameter.c0/(2*radarParameter.B);  % convert to metric units
%%
% detect targets velocity
targetList = [];
actIndexList = [];
% loop to calculate the velocity
for actRangeTarg = 1 : numel(rangeSpecMaxPos)
    actRangeBin = rangeSpecMaxPos(actRangeTarg);
    
    % sum every layer after fft
    actVelSpec = arrayResponse_3D(actRangeBin,:,:);
    actVelSpecSum = sum(abs(actVelSpec).^2, 3);
    actVelSpecSum = actVelSpecSum.';
    % define velocity cfar detector 
    vel_detector = phased.CFARDetector('Method', 'OS', 'NumTrainingCells', numTrainingCells,...
    'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
      'Rank', 15);    % return a row;   
  
    % got the binary Mask after cfar
    CFAR_binaryMask = vel_detector(actVelSpecSum, 1: numel(actVelSpecSum));
    
    if any(CFAR_binaryMask) % if the velocity are availabel
    
    % cluster to find different velocity
    velSpecMaxPos = clusterCFARMask(actVelSpecSum, CFAR_binaryMask);
    
    % peak detection and interpolation to get the real maxIndes and peak value
    peakPos = peakInterp(velSpecMaxPos, actVelSpecSum);   

    % convert to metric units
    velDetections = (zeroPadingFactor * radarParameter.N_chirp/2 - peakPos + 1) / zeroPadingFactor ...   % -1 or not or + 1, I think + 1 is right?
                    * radarParameter.c0/radarParameter.T_chirp / (2 *...
                    radarParameter.f0 * radarParameter.N_chirp);
    
    % angle estimation
    for actVelTarg = 1 : numel(velSpecMaxPos)
        actVelBin = velSpecMaxPos(actVelTarg);
        arrayResponse = squeeze(actVelSpec(:, actVelBin, :));

        angle = DOAEstimator_2D(arrayResponse, ...
        rangeDetections(actRangeTarg), velDetections(actVelTarg), radarParameter);
    
        %create a target information
        actIndex = [rangeSpecMaxPos(actRangeTarg), velSpecMaxPos(actVelTarg)];
        actTargets = [rangeDetections(actRangeTarg), velDetections(actVelTarg), angle];
        targetList = [actTargets; targetList];
        actIndexList = [actIndex; actIndexList];

    end
    end
end


% 画range ux时，保证vr和uy不同，若相同则把目标去除
% 画range uy时，保证vr和uy不同，若相同则把目标去除
%%
list = [actIndexList, targetList];
% list has 6 column: [range_index, vr_index, range, vr, ux, uy];

% delete same vr and uy
list_range_ux = delete_same(list, 2, 6);
% delete same vr and ux
list_range_uy = delete_same(list, 2, 5);

range_ux = [];
range_uy = [];

% plot range ux
for i = 1 : size(list_range_ux, 1)
arrayResponse_2D = squeeze(arrayResponse_3D(:, list_range_ux(i, 2), :));
norm_cost_func_ux = range_ux_figure(arrayResponse_2D,...
                    list_range_ux(i, 4), list_range_ux(i, 6), radarParameter);
if(~any(range_ux))
    range_ux = norm_cost_func_ux;
else
    range_ux = range_ux + norm_cost_func_ux;
end
end

% plot range uy
for i = 1 : size(list_range_uy, 1)
arrayResponse_2D = squeeze(arrayResponse_3D(:, list_range_uy(i, 2), :));
norm_cost_func_uy = range_uy_figure(arrayResponse_2D, ...
                    list_range_uy(i, 4), list_range_uy(i, 5), radarParameter);           
if(~any(range_uy))
    range_uy = norm_cost_func_uy;
else
    range_uy = range_uy + norm_cost_func_uy;
end
end

function [list] = delete_same(list, d1, d2)
% delete the target that has same value in d1 and d2 dimension

list = sortrows(list, d1);
list = sortrows(list, d2);
if any(list)
    temp1 = list(1, d1);
    temp2 = list(1, d2);
end

delList = [];  % pick same volocity
if(size(list, 1) >= 2)
    for n = 2 : size(list, 1)
        if (abs(temp1 - list(n, d1)) <= 1e-4 && abs(temp2 - list(n, d2)) <= 1e-4)
            delList = [n, delList];
        else
           temp1 = list(n, d1);
           temp2 = list(n, d2);
        end
    end
end

% delete the same value
list(delList, :) = [];
end

end