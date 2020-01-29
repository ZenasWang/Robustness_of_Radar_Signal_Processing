% function [targetList, range_ux, range_uy] = new_signalProcessing( rawData, radarParameter )
% signal Processing of the Radar Signal to get the
% output as a dected target list with estimated range, velocity and DOA

% - rawData         := the simulated signal with noise
% - radarParameter  := defined radar parameters
% - targetList      := estimated tagets information [range, speed, ux, uy]
% - range_ux        := matix of range_ux_figure
% - range_uy        := matix of range_uy_figure

rawData = rawData4;

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
list = sortrows(list, 2);
if any(list)
    vel = list(1, 2);
end
delList = [];
if(size(list, 1) >= 2)
for i = 2 : size(list, 1)
    if vel == list(i, 2)
        delList = [i, delList];
    else
       vel = list(i, 2);
    end
end

for i = 1 : numel(delList)
    list(i, :) = [];
end
% delList = [];
% 
% if(size(list, 1) >= 2)
% list = sortrows(list, 6);
% uy = list(1, 6);
% for i = 2 : size(list, 1)
%     if abs(uy - list(i, 6)) <= 1e-4
%         delList = [i, delList];
%     else
%        uy = list(i, 6);
%     end
% end
% for i = 1 : numel(delList)
%     list(i, :) = [];
% end
% end
end   
%%
list
range_ux = [];
range_uy = [];

for i = 1 : size(list, 1)
arrayResponse_2D = squeeze(arrayResponse_3D(:, list(i, 2), :));
norm_cost_func_ux = range_ux_figure(arrayResponse_2D, list(i, 3)...
    , list(i, 4), list(i, 6), radarParameter);
norm_cost_func_uy = range_uy_figure(arrayResponse_2D, list(i, 3)...
    , list(i, 4), list(i, 5), radarParameter);

if(~any(range_ux))
            range_ux = norm_cost_func_ux;
            range_uy = norm_cost_func_uy;
        else
            range_ux = range_ux + norm_cost_func_ux;
            range_uy = range_uy + norm_cost_func_uy;
end
end

subplot(1, 2, 1);
plot_range_DOA(range_ux, "ux");

subplot(1, 2, 2);
plot_range_DOA(range_uy, "uy");

% end