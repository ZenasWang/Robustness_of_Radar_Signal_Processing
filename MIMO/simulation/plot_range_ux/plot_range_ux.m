% generate relavent data for test
clc;
clear;

objectParameter1 = defineObject(60, 10, [0.5, 0.2], 1, 10);
objectParameter2 = defineObject(20, 20, [-0.3,0.4], 1, 10);

[Tx, Rx] = random_arrays_2D(32, 20, 4, true);% without wavelength

radarParameter = defineRadar(77e9, 224e6, 20.36e6, 256, 238, Tx, Rx);
% min_interval = 0.0001;
% Y = [Tx;Rx];
% 
% while(min_distance_1D(Y(:,1)) <= min_interval/(radarParameter.wavelength/2) || ...
%       min_distance_1D(Y(:,2)) <= min_interval/(radarParameter.wavelength/2))
%     [Tx, Rx] = random_arrays_2D(32, 20, 4, true);% without wavelength
%     radarParameter = defineRadar(77e9, 224e6, 20.36e6, 256, 238, Tx, Rx);
% end

% radarParameter.P = opm_P;
rawData1 = signalGenerator_SO(radarParameter, objectParameter1);
rawData2 = signalGenerator_SO(radarParameter, objectParameter1)...
         + signalGenerator_SO(radarParameter, objectParameter2);


rawData = rawData2;

numTrainingCells = 40;
numGuardCells = 4;
probabilityFalseAlarm = 1e-5;
zeroPadingFactor = 3;
radarData = rawData;


arrayResponse_3D = fft2(radarData, zeroPadingFactor * size(radarData, 1), ...
                        zeroPadingFactor * size(radarData, 2));
arrayResponse_3D = fftshift(arrayResponse_3D, 2);

actVelSpecSum = sum(sum(abs(arrayResponse_3D).^2, 1), 3)';

% define velocity cfar detector 
vel_detector = phased.CFARDetector('Method', 'OS', 'NumTrainingCells', numTrainingCells,...
'NumGuardCells', numGuardCells, 'ProbabilityFalseAlarm', probabilityFalseAlarm, ...
  'Rank', 15);    % return a row;   

% got the binary Mask after cfar
CFAR_binaryMask = vel_detector(actVelSpecSum, 1: numel(actVelSpecSum));


% cluster to find different velocity
velSpecMaxPos = clusterCFARMask(actVelSpecSum, CFAR_binaryMask');

% peak detection and interpolation to get the real maxIndes and peak value
peakPos = peakInterp(velSpecMaxPos, actVelSpecSum);   

% convert to metric units
velDetections = (zeroPadingFactor * radarParameter.N_chirp/2 - peakPos + 1) / zeroPadingFactor ...   % -1 or not or + 1, I think + 1 is right?
                * radarParameter.c0/radarParameter.T_chirp / (2 *...
                radarParameter.f0 * radarParameter.N_chirp);


%%

tpn = [-radarParameter.N_Tx/2 : -1, 1 : radarParameter.N_Tx/2] * radarParameter.T_pn;
E = 2*pi /radarParameter.c0 * [2 * radarParameter.f0 * kron(tpn', ones([radarParameter.N_Rx,1])),...
                                radarParameter.f0 * radarParameter.P];

                            
ux = -1 : 0.01 : 1;
uy = -1 : 0.1 : 1; 

cost_func_sum = zeros(numel(velSpecMaxPos), size(arrayResponse_3D, 1),...
                numel(ux));
            
cost_func = zeros(size(arrayResponse_3D, 1), numel(ux));

for vel_ind = 1 : numel(velSpecMaxPos)
    arrayResponse_2D = arrayResponse_3D(:, velSpecMaxPos(vel_ind), :);
    arrayResponse_2D = squeeze(arrayResponse_2D);
    
    for i = 1 : numel(ux)
        for j = 1 : numel(uy)
            X_ideal = exp(1j * E * [velDetections(vel_ind); ux(i); uy(j)]);
            for k = 1 : size(arrayResponse_3D, 1)
                cost_func(k, i, j) = ...
                abs(arrayResponse_2D(k, :)* X_ideal).^2;
            end
        end
    end
    
    cost_func_temp = squeeze(sum(cost_func, 1));
    [ux_ind, uy_ind] = find(cost_func_temp == max(cost_func_temp(:)));
    
    norm_cost_func = cost_func(:, :, uy_ind);
    norm_cost_func = norm_cost_func / max(norm_cost_func(:));
    cost_func_sum(vel_ind, :,:) = norm_cost_func;
end

% vr = -30 : 1 : 30;
% arrayResponse_2D = squeeze(arrayResponse_3D(:, 1, :));

%
% cost_func_sum = squeeze(sum(cost_func, [2,3,4]));
% v_max_ind = find(cost_func_sum == max(cost_func_sum(:)));
% cost_func_sum_range = squeeze(sum(cost_func, 2));
% ind = find(cost_func_sum_range == max(cost_func_sum_range(:)));
% [vr_ind, ux_ind, uy_ind] = ind2sub(size(cost_func_sum_range),ind);
cost_func_sum = sum(cost_func_sum, 1);

%%
contourf(squeeze(cost_func_sum(1,:,:)), 100, 'linestyle', 'none');
% axis('equal');
xlabel('ux')
ylabel('r0')
xticks('auto')
yticks('auto')
c_r=colorbar;
ylabel(c_r,'beta') 
