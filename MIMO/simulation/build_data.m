% generate relavent data for test
clc;
clear;

objectParameter1 = defineObject(60, 10, [0,0], 1, 10);
% objectParameter2 = defineObject(80, 10, [0,0], 1, 10);

[Tx, Rx] = random_arrays_2D(32, 20, 4, true);% without wavelength

radarParameter = defineRadar(77e9, 224e6, 20.36e6, 256, 238, Tx, Rx);
% radarParameter.P = opm_P;
rawData = signalGenerator_SO(radarParameter, objectParameter1);

numTrainingCells = 40;
numGuardCells = 4;
probabilityFalseAlarm = 1e-5;

radarData = rawData;

% sum every layer after fft
actVelSpec = fftshift(fft(rawData, size(radarData, 2), 2),2); % sqrt(size(radarData, 2))
actVelSpecSum = sum(sum(abs(actVelSpec).^2, 1),3);
actVelSpecSum = squeeze(actVelSpecSum);


% define velocity cfar detector
vel_detector = phased.CFARDetector('Method', 'OS', 'NumTrainingCells', numTrainingCells,...
'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
  'Rank', 15);    % return a row;   
  
% got the binary Mask after cfar
CFAR_binaryMask = vel_detector(actVelSpecSum', 1: numel(actVelSpecSum));

% cluster to find different velocity
velSpecMaxPos = clusterCFARMask(actVelSpecSum, CFAR_binaryMask');

% 1D-fft range to detect targets in range direction
% fft_range = fft2(radarData, 3*size(radarData, 1), 3*size(radarData, 2)); % * sqrt(size(radarData, 1))
% rangeSpec = sum(fft_range, 2);
% rangeSpec_sum = sum(rangeSpec, 3).^2; % N_sample x 1

arrayResponse = fft(actVelSpec(:, velSpecMaxPos, :), size(rawData, 1), 1);
arrayResponse = squeeze(arrayResponse);
stem(abs(arrayResponse(:,5)))
% arrayResponse = squeeze(rangeSpec);

tpn = [-radarParameter.N_Tx/2 : -1 1 : radarParameter.N_Tx/2] * radarParameter.T_pn;

E = -2*pi /radarParameter.c0 * radarParameter.f0 * radarParameter.P;
                                           
ux = -1 : 0.01 : 1;
uy = -1 : 0.01 : 1;
% range = 0 : 237;
% range = (radarParameter.N_sample - range + 1) * radarParameter.c0/(2*radarParameter.B);
% Ambi = zeros(numel(v), numel(ux));
for i = 1 : numel(ux)
    for k = 1 : size(arrayResponse, 1)
        X_ideal = exp(1j * E * [ux(i); 0]);
        cost_func(k, i) = abs((arrayResponse(k, :).')' * X_ideal).^2;  
    end
end

% plot(cost_func)
% 
contourf(cost_func, 100, 'linestyle', 'none');
% axis('equal');
xlabel('ux')
ylabel('r0')
xticks('auto')
yticks('auto')
c_r=colorbar;
ylabel(c_r,'beta') 



% % sum of all range spectra of the antennas
% rangeSpec_sum = sum(rangeSpec, 3).^2; % N_sample x 1
% 
% % detect targets range
% % set the detector parameter, os-cfar detector
% range_detector = phased.CFARDetector('Method', 'OS', 'NumTrainingCells', numTrainingCells,...
%     'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
%       'Rank', 15);
%   
% % get the binary Mask after cfar
% CFAR_binaryMask = range_detector(rangeSpec_sum, 1:numel(rangeSpec_sum));
% 
% % cluster to find the different target
% rangeSpecMaxPos = clusterCFARMask(rangeSpec_sum, CFAR_binaryMask');
%     
% % sum every layer after fft
% actVelSpec = fftshift(fft(fft_range(rangeSpecMaxPos,:,:), zeroPadingFactor*size(radarData, 2),2),2); % sqrt(size(radarData, 2))
% actVelSpecSum = (sum(abs(actVelSpec), 3).^2);
% actVelSpecSum = reshape(actVelSpecSum, numel(actVelSpecSum), 1);
% 
% % define velocity cfar detector
% vel_detector = phased.CFARDetector('Method', 'OS', 'NumTrainingCells', numTrainingCells,...
% 'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
%   'Rank', 15);    % return a row;   
%   
% % got the binary Mask after cfar
% CFAR_binaryMask = vel_detector(actVelSpecSum, 1: numel(actVelSpecSum));
% 
% % cluster to find different velocity
% velSpecMaxPos = clusterCFARMask(actVelSpecSum, CFAR_binaryMask');
% 
% arrayResponse = squeeze(actVelSpec(:, velSpecMaxPos, :));
% a = arrayResponse .* arrayResponse;
% plot(abs(arrayResponse));
% Ambi = zeros(numel(v), numel(ux));
% for i = 1 : numel(ux)
% for k = 1 : numel(range)
%     Ambi(k) = ambiguity_func(range(k), radarParameter, objectParameter);
% end


% end
% Ambi = Ambi/ max(Ambi(:));
% stem(Ambi);
