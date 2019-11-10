function [ targetList ] = signalProcessing( rawData, radarParameters )
%RADARSIGNALPROCESSING: Signal Processing of the Radar Signal to get the
%output as a dected target list with estimated range, velocity and DOA

% Defs
% CFAR Definition

% rawData = radarSignal_4;
% radarParameters = radarParameter;

numTrainingCells = 20;
numGuardCells = 2;
probabilityFalseAlarm = 1e-5;

% Window
windowData = repmat(chebwin(size(rawData, 1), 60) * chebwin(size(rawData, 2), 60)' , 1, 1, size(rawData, 3));
radarData = rawData .* windowData;

% 1D-fft range to detect targets in range direction

fft_range = sqrt(size(radarData, 1)) * fft(radarData, size(radarData, 1), 1);
rangeSpec = sum(abs(fft_range), 2);

% sum of all range spectra of the antennas
rangeSpec_sum = sum(rangeSpec, 3); % N_sample x 1

% detect targets range
range_detector = phased.CFARDetector('Method', 'OS','NumTrainingCells', numTrainingCells,...
    'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
     'Rank', 15);  %'ThresholdFactor', 'Custom', 'CustomThresholdFactor', 1.5); % return a row;

CFAR_binaryMask = range_detector(rangeSpec_sum, 1:numel(rangeSpec_sum));
[rangeSpecMaxPos] = clusterCFARMask(rangeSpec_sum,CFAR_binaryMask');

% [peakPos, ~, rangeCoarseInd] = peakInterp(rangeSpecMaxPos, radarData, false);          % Interpolation to estimate the range
[peakPos,~]=peakInterp(rangeSpecMaxPos,radarData,false);
rangeDetections = (radarParameters.N_sample - peakPos + 1) * radarParameters.c0/(2*radarParameters.B);  % convert to metric units
% detect targets velocity

targetList=[];
for actRangeTarg = 1 : numel(rangeSpecMaxPos)
    actRangeBin = rangeSpecMaxPos(actRangeTarg);
    actVelSpec = (fftshift(fft(fft_range(actRangeBin,:,:), size(radarData, 2),2)));
    actVelSpecSum = sum(abs(actVelSpec), 3)';
    
    vel_detector = phased.CFARDetector('Method', 'OS', 'NumTrainingCells', numTrainingCells,...
    'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
      'Rank', 15);    % return a row;   
    
    CFAR_binaryMask = vel_detector(actVelSpecSum, 1: numel(actVelSpecSum));
    
    if any(CFAR_binaryMask)
    [velSpecMaxPos]=clusterCFARMask(actVelSpec,CFAR_binaryMask');
    [peakPos,peakAmpl] = peakInterp(velSpecMaxPos, radarData, true);   % Interpolation to estimate the velocity
    
    % convert to metric units
    velDetections = (radarParameters.N_chirp/2 - peakPos - 1)*...   % -1 or not?
                radarParameters.c0/radarParameters.T_chirp / (2 *...
                radarParameters.f0(1) * radarParameters.N_chirp);   
    
    actTargets = [repmat(rangeDetections(actRangeTarg), numel(velDetections), 1),...
                velDetections, peakAmpl];
    else
        actTargets=[];
    end
    targetList = [actTargets; targetList];
end
end


