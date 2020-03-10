% function [MSE_r0, MSE_vr,MSE_ux] = monte_carlo(radarParameter, objectParameter)
clc
clear 
close all;

load('/Users/wang/Documents/Forschungsarbeit/Robustness_of_Radar_Signal_Processing/MIMO/Opimization/ES_algorithm_2D/ES_results/ES_results_4x4_SNR-5.mat')

[Tx, Rx] = rectangular_arrays_2D(4, 4); % without wavelength
% [Tx, Rx] = random_arrays_2D(4, 4, 4, false);
radarParameter_normal = defineRadar(77e9, 224e6, 20.36e6, 256, 238, Tx, Rx);
radarParameter_optimal = defineRadar(77e9, 224e6, 20.36e6, 256, 238, opt_Tx, opt_Rx);

P_normal = to_virture_arrays(Tx, Rx, radarParameter_normal);
P_optimal = to_virture_arrays(opt_Tx, opt_Rx, radarParameter_optimal);

r0 = 80;
v= 10;
A = 1;
ux = -0.41232;
uy = 0.14324;
SNR = -10: 5: 30;
T = 100;

% targetList_normal = zeros(numel(SNR), T, 2);
% targetList_optimal = zeros(numel(SNR), T, 2);

objectParameter = defineObject(r0, v, [ux,uy], A, 10);
%%
for SNR_i = 1 : numel(SNR)
    parfor i = 1 : T
        
    radarSignal_normal = array_response(radarParameter_normal, objectParameter, SNR(SNR_i));
    radarSignal_optimal = array_response(radarParameter_optimal, objectParameter, SNR(SNR_i));

    targetList_optimal(SNR_i, i, :) = DOA_for_array_response(radarSignal_optimal, radarParameter_optimal);
    targetList_normal(SNR_i, i, :) = DOA_for_array_response(radarSignal_normal, radarParameter_normal);
    end
end

%%
MSE_normal = zeros(numel(SNR), 2);
MSE_optimal = zeros(numel(SNR), 2);

for SNR_i = 1 : numel(SNR)
MSE_normal(SNR_i, :) = 1/T * sum((squeeze(targetList_normal(SNR_i,:,:)) - [ux, uy]).^2, 1);
MSE_optimal(SNR_i, :) = 1/T * sum((squeeze(targetList_optimal(SNR_i,:,:)) - [ux, uy]).^2, 1);
end

MSE_normal_show = sum(MSE_normal, 2);
MSE_optimal_show = sum(MSE_optimal, 2);
% MSE_normal_show = MSE_normal(:, 1);
% MSE_optimal_show = MSE_optimal(:, 1);

for SNR_i = 1 : numel(SNR)
CRB_normal(SNR_i) = sum(diag(CRB_only_for_DOA(radarParameter_normal.P, radarParameter_normal, objectParameter, SNR(SNR_i))));
CRB_optimal(SNR_i) = sum(diag(CRB_only_for_DOA(radarParameter_optimal.P, radarParameter_optimal, objectParameter, SNR(SNR_i))));
% CRB_2D_normal = CRB_only_for_DOA(radarParameter_normal.P, radarParameter_normal, objectParameter, SNR(SNR_i));
% CRB_normal(SNR_i) = CRB_2D_normal(1,1);
% CRB_2D_optimal = CRB_only_for_DOA(radarParameter_optimal.P, radarParameter_optimal, objectParameter, SNR(SNR_i));
% CRB_optimal(SNR_i) = CRB_2D_optimal(1,1);
end

%%
semilogy(SNR, CRB_normal, 'r');
hold on;
semilogy(SNR, CRB_optimal, 'b');
semilogy(SNR, MSE_normal_show, '--r');
semilogy(SNR, MSE_optimal_show, '--b');

fprintf("before optimization: CRB: %.5e, MSE: %.5e \n ", CRB_normal(2), MSE_normal_show(2));
fprintf("before optimization: CRB: %.5e, MSE: %.5e \n ", CRB_optimal(2), MSE_optimal_show(2));

% end