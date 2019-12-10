% function [targetList] = signalProcessing( rawData, radarParameter )
%RADARSIGNALPROCESSING: Signal Processing of the Radar Signal to get the
%output as a dected target list with estimated range, velocity and DOA

% example setting for try
radarParameter = defineRadar(77e9 , 3e9, 10e6,...
                           160, 1000, [0,0,0], [0,0,0;1,0,0;0,1,0;1,1,0;0,2,0;2,0,0;2,1,0;1,2,0;2,2,0]);
objectParameter1 = defineObject(15, 2, [0.5,0.3,0], 1, -16);
objectParameter2 = defineObject(15, 2, [0.5,0.3,0], 1, -5);
radarSignal1 = signalGenerator_SO(radarParameter, objectParameter1);
radarSignal2 = signalGenerator_SO(radarParameter, objectParameter2);
rawData = radarSignal1;

% define cfar parameters
numTrainingCells = 20;
numGuardCells = 2;
probabilityFalseAlarm = 1e-5;

% Window
windowData = repmat(chebwin(size(rawData, 1), 60) * chebwin(size(rawData, 2), 60)' , 1, 1, size(rawData, 3));
% windowData=repmat(chebwin(size(rawData,1)),1,...
%     size(rawData,2),size(rawData,3));
radarData = rawData .* windowData;

% 1D-fft range to detect targets in range direction
fft_range = fft(radarData, size(radarData, 1), 1); % * sqrt(size(radarData, 1)) 
rangeSpec = sum(abs(fft_range).^2, 2);
% sum of all range spectra of the antennas
rangeSpec_sum = sum(rangeSpec, 3); % N_sample x 1
% plot(rangeSpec_sum)
% ax = axes;
% plot(abs(fft_range(:,1,1)))
% ax.YGrid = 'on';
% ax.YScale = 'log';

% detect targets range
% set the detector parameter, os-cfar detector
range_detector = phased.CFARDetector('Method', 'OS', 'NumTrainingCells', numTrainingCells,...
    'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
      'Rank', 15);  % return a row;
% got the binary Mask after cfar
CFAR_binaryMask = range_detector(rangeSpec_sum, 1:numel(rangeSpec_sum));
% cluster to find the different target
[rangeSpecMaxPos] = clusterCFARMask(rangeSpec_sum, CFAR_binaryMask');
% peak detection and interpolation to got the real maxIndes
[peakPos,~] = peakInterp(rangeSpecMaxPos,radarData,false);
% map to real ranges
rangeDetections = (radarParameter.N_sample - peakPos + 1) * radarParameter.c0/(2*radarParameter.B);  % convert to metric units
                                              % +1 or not
% detect targets velocity
targetList=[];
% loop to calculate the velocity
for actRangeTarg = 1 : numel(rangeSpecMaxPos)
    actRangeBin = rangeSpecMaxPos(actRangeTarg);
    
    % sum every layer after fft
    actVelSpec = fftshift(fft(fft_range(actRangeBin,:,:), size(radarData, 2),2),2); % sqrt(size(radarData, 2))
    actVelSpecSum = sum(abs(actVelSpec).^2, 3)';
    
    % define velocity cfar detector 
    vel_detector = phased.CFARDetector('Method', 'OS', 'NumTrainingCells', numTrainingCells,...
    'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
      'Rank', 15);    % return a row;   
    
    % got the binary Mask after cfar
    CFAR_binaryMask = vel_detector(actVelSpecSum, 1: numel(actVelSpecSum));
    
    if any(CFAR_binaryMask) % if the velocity are availabel
    % cluster to find different velocity
    [velSpecMaxPos] = clusterCFARMask(actVelSpecSum, CFAR_binaryMask');
    
    % peak detection and interpolation to get the real maxIndes and peak value
    [peakPos,peakAmpl] = peakInterp(velSpecMaxPos, fft_range(actRangeBin,:,:), true);   
    
    % convert to metric units
    velDetections = (radarParameter.N_chirp/2 - peakPos + 1)*...   % -1 or not or + 1, I think + 1 is right?
                radarParameter.c0/radarParameter.T_chirp / (2 *...
                radarParameter.f0(1) * radarParameter.N_chirp);

    % angle estimation
        angle = zeros(numel(peakPos),2);
        for actVelTarg = 1 : numel(velSpecMaxPos)
            actVelBin = velSpecMaxPos(actVelTarg);
            arrayResponse = squeeze(actVelSpec(:, actVelBin, :));
            angle(actVelTarg, :) = DOAEstimator_2D(arrayResponse, radarParameter, ...
            rangeDetections(actRangeTarg), velDetections(actVelTarg));
        end
    %create a target information
    actTargets = [repmat(rangeDetections(actRangeTarg), numel(velDetections), 1),...
                velDetections, angle, peakAmpl];
    else
        actTargets=[];
    end
    targetList = [actTargets; targetList];
%     pulse_compression = [ pulse_compression_row;pulse_compression];
end
% end