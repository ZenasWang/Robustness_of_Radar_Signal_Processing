function [targetList] = signalProcessing( rawData, radarParameter )
% signal Processing of the Radar Signal to get the
% output as a dected target list with estimated range, velocity and DOA

% - rawData         := the simulated signal with noise
% - radarParameter  := defined radar parameters
% - targetList      := estimated tagets information [range, speed, ux, uy]

% define cfar parameters
numTrainingCells = 40;
numGuardCells = 4;
probabilityFalseAlarm = 1e-5;
zeroPadingFactor = 3;

% Window
% windowData = repmat(chebwin(size(rawData, 1), 30) * chebwin(size(rawData, 2), 30)' , 1, 1, size(rawData, 3));
% windowData=repmat(chebwin(size(rawData,1)),1, size(rawData,2),size(rawData,3));
% radarData = rawData.* windowData;
radarData = rawData;

% 1D-fft range to detect targets in range direction
fft_range = fft(radarData, zeroPadingFactor * size(radarData, 1), 1); % * sqrt(size(radarData, 1)) 
rangeSpec = sum(abs(fft_range), 2);

% sum of all range spectra of the antennas
rangeSpec_sum = sum(rangeSpec, 3).^2; % N_sample x 1

% detect targets range

% set the detector parameter, os-cfar detector
range_detector = phased.CFARDetector('Method', 'OS', 'NumTrainingCells', numTrainingCells,...
    'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
      'Rank', 15);
  
% get the binary Mask after cfar
CFAR_binaryMask = range_detector(rangeSpec_sum, 1:numel(rangeSpec_sum));

% cluster to find the different target
rangeSpecMaxPos = clusterCFARMask(rangeSpec_sum, CFAR_binaryMask');

% peak detection and interpolation to got the real maxIndes
peakPos = peakInterp(rangeSpecMaxPos, rangeSpec_sum);

% map to real ranges
rangeDetections = (zeroPadingFactor * radarParameter.N_sample - peakPos + 1)/zeroPadingFactor ...
        * radarParameter.c0/(2*radarParameter.B);  % convert to metric units

% detect targets velocity
targetList = [];

% loop to calculate the velocity
for actRangeTarg = 1 : numel(rangeSpecMaxPos)
    actRangeBin = rangeSpecMaxPos(actRangeTarg);
    
    % sum every layer after fft
    actVelSpec = fftshift(fft(fft_range(actRangeBin,:,:), zeroPadingFactor*size(radarData, 2),2),2); % sqrt(size(radarData, 2))
    actVelSpecSum = (sum(abs(actVelSpec), 3).^2);
    actVelSpecSum = reshape(actVelSpecSum, numel(actVelSpecSum), 1);
    
    % define velocity cfar detector 
    vel_detector = phased.CFARDetector('Method', 'OS', 'NumTrainingCells', numTrainingCells,...
    'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
      'Rank', 15);    % return a row;   
  
    % got the binary Mask after cfar
    CFAR_binaryMask = vel_detector(actVelSpecSum, 1: numel(actVelSpecSum));
    
    if any(CFAR_binaryMask) % if the velocity are availabel
    
    % cluster to find different velocity
    velSpecMaxPos = clusterCFARMask(actVelSpecSum, CFAR_binaryMask');
    
    % peak detection and interpolation to get the real maxIndes and peak value
    peakPos = peakInterp(velSpecMaxPos, actVelSpecSum);   

    % convert to metric units
    velDetections = (zeroPadingFactor * radarParameter.N_chirp/2 - peakPos + 1) / zeroPadingFactor ...   % -1 or not or + 1, I think + 1 is right?
                    * radarParameter.c0/radarParameter.T_chirp / (2 *...
                    radarParameter.f0 * radarParameter.N_chirp);
                    % convert to metric units
    
    % angle estimation
    angle = zeros(numel(peakPos),2);
    for actVelTarg = 1 : numel(velSpecMaxPos)
        actVelBin = velSpecMaxPos(actVelTarg);
        arrayResponse = squeeze(actVelSpec(:, actVelBin, :));
        angle(actVelTarg, :) = DOAEstimator_2D(arrayResponse, ...
        rangeDetections(actRangeTarg), velDetections(actVelTarg), radarParameter);
    end
    
    %create a target information
    actTargets = [repmat(rangeDetections(actRangeTarg), numel(velDetections), 1),...
                velDetections, angle];
    else
        actTargets=[];
    end
    targetList = [actTargets; targetList];
end
end