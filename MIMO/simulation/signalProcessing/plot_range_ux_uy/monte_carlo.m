% function [MSE_r0, MSE_vr,MSE_ux] = monte_carlo(radarParameter, objectParameter)
clc
clear 

load('/Users/wang/Documents/Forschungsarbeit/Robustness_of_Radar_Signal_Processing/MIMO/Opimization/ES_algorithm_2D/ES_results/ES_results_4x4_SNR-5.mat')
[Tx, Rx] = rectangular_arrays_2D(4, 4); % without wavelength

radarParameter_normal = defineRadar(77e9, 224e6, 20.36e6, 256, 238, Tx, Rx);
radarParameter_optimal = defineRadar(77e9, 224e6, 20.36e6, 256, 238, opt_Tx, opt_Rx);

r0 = 80;
v= 10;
A = 1;
ux = 0.3;
uy = 0.3;
SNR = -10: 5: 5;
T = 10;

%%
targetList_normal = zeros(numel(SNR), T, 4);
targetList_optimal = zeros(numel(SNR), T, 4);

for SNR_i = 1 : numel(SNR)
    objectParameter(SNR_i) = defineObject(r0, v, [ux,uy], A, SNR(SNR_i));
    parfor i = 1 : T
    radarSignal_normal = signalGenerator_SO(radarParameter_normal, objectParameter(SNR_i));
    targetList_normal(SNR_i, i, :) = new_signalProcessing(radarSignal_normal, radarParameter_normal);
    radarSignal_optimal = signalGenerator_SO(radarParameter_optimal, objectParameter(SNR_i));
    targetList_optimal(SNR_i, i, :) = new_signalProcessing(radarSignal_optimal, radarParameter_optimal);
    end
end

%%

MSE_normal = zeros(numel(SNR), 4);
MSE_optimal = zeros(numel(SNR), 4);

for SNR_i = 1 : numel(SNR)
MSE_normal(SNR_i, :) = 1/T * sum((squeeze(targetList_normal(SNR_i,:,:)) - [r0, v, ux, uy]).^2, 1);
MSE_optimal(SNR_i, :) = 1/T * sum((squeeze(targetList_optimal(SNR_i,:,:)) - [r0, v, ux, uy]).^2, 1);
end

MSE_normal_show = sum(MSE_normal(:, 3:4), 2);
MSE_optimal_show = sum(MSE_optimal(:, 3:4), 2);

for SNR_i = 1 : numel(SNR)
CRB_normal(SNR_i) = sum(diag(CRB_func_2D(radarParameter_normal.P, radarParameter_normal, objectParameter(SNR_i))));
CRB_optimal(SNR_i) = sum(diag(CRB_func_2D(radarParameter_optimal.P, radarParameter_optimal, objectParameter(SNR_i))));
end

semilogy(SNR, CRB_normal, 'b');
hold on;
semilogy(SNR, CRB_optimal, 'r');
semilogy(SNR, MSE_normal_show, '--g');
semilogy(SNR, MSE_optimal_show, '--y');

fprintf("before optimization: CRB: %.5e, MSE: %.5e \n ", CRB_normal(2), MSE_normal_show(2));
fprintf("before optimization: CRB: %.5e, MSE: %.5e \n ", CRB_optimal(2), MSE_optimal_show(2));


% end

