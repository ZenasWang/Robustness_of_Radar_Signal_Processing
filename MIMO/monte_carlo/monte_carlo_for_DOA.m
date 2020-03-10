% function [MSE_r0, MSE_vr,MSE_ux] = monte_carlo(radarParameter, objectParameter)
clc
clear 
close all;

load('ES_opti_array.mat');

[rect_Tx, rect_Rx] = rectangular_arrays_2D(4, 4); % without wavelength
[cross_Tx, cross_Rx] = cross_arrays_2D_4x4();
radarParameter_rect = defineRadar(77e9, 224e6, 20.36e6, 256, 238, rect_Tx, rect_Rx);
radarParameter_optimal = defineRadar(77e9, 224e6, 20.36e6, 256, 238, opt_Tx, opt_Rx);
radarParameter_cross = defineRadar(77e9, 224e6, 20.36e6, 256, 238, cross_Tx, cross_Rx);

r0 = 80;
v= 10;
A = 1;
ux = -0.41232;
uy = 0.14324;
SNR = -10: 5: 40;
T = 1000;

% targetList_normal = zeros(numel(SNR), T, 2);
% targetList_optimal = zeros(numel(SNR), T, 2);

objectParameter = defineObject(r0, v, [ux,uy], A, 10);
%%
for SNR_i = 1 : numel(SNR)
    parfor i = 1 : T
        
    radarSignal_rect = array_response(radarParameter_rect, objectParameter, SNR(SNR_i));
    radarSignal_optimal = array_response(radarParameter_optimal, objectParameter, SNR(SNR_i));
    radarSignal_cross = array_response(radarParameter_cross, objectParameter, SNR(SNR_i));
    targetList_optimal(SNR_i, i, :) = DOA_for_array_response(radarSignal_optimal, radarParameter_optimal);
    targetList_rect(SNR_i, i, :) = DOA_for_array_response(radarSignal_rect, radarParameter_rect);
    targetList_cross(SNR_i, i, :) = DOA_for_array_response(radarSignal_cross, radarParameter_cross);
    end
end

%%
MSE_cross = zeros(numel(SNR), 2);
MSE_optimal = zeros(numel(SNR), 2);
MSE_rect = zeros(numel(SNR), 2);

for SNR_i = 1 : numel(SNR)
MSE_rect(SNR_i, :) = 1/T * sum((squeeze(targetList_rect(SNR_i,:,:)) - [ux, uy]).^2, 1);
MSE_optimal(SNR_i, :) = 1/T * sum((squeeze(targetList_optimal(SNR_i,:,:)) - [ux, uy]).^2, 1);
MSE_cross(SNR_i, :) = 1/T * sum((squeeze(targetList_cross(SNR_i,:,:)) - [ux, uy]).^2, 1);
end

MSE_rect_show = sum(MSE_rect, 2);
MSE_optimal_show = sum(MSE_optimal, 2);
MSE_cross_show = sum(MSE_cross, 2);
% MSE_normal_show = MSE_normal(:, 1);
% MSE_optimal_show = MSE_optimal(:, 1);

for SNR_i = 1 : numel(SNR)
CRB_rect(SNR_i) = sum(diag(CRB_only_for_DOA(radarParameter_rect.P, radarParameter_rect, objectParameter, SNR(SNR_i))));
CRB_optimal(SNR_i) = sum(diag(CRB_only_for_DOA(radarParameter_optimal.P, radarParameter_optimal, objectParameter, SNR(SNR_i))));
CRB_cross(SNR_i) = sum(diag(CRB_only_for_DOA(radarParameter_cross.P, radarParameter_cross, objectParameter, SNR(SNR_i))));

% CRB_2D_normal = CRB_only_for_DOA(radarParameter_normal.P, radarParameter_normal, objectParameter, SNR(SNR_i));
% CRB_normal(SNR_i) = CRB_2D_normal(1,1);
% CRB_2D_optimal = CRB_only_for_DOA(radarParameter_optimal.P, radarParameter_optimal, objectParameter, SNR(SNR_i));
% CRB_optimal(SNR_i) = CRB_2D_optimal(1,1);
end

%%
semilogy(SNR, CRB_cross, 'g');
hold on;
semilogy(SNR, CRB_optimal, 'r');
semilogy(SNR, CRB_rect, 'b');
semilogy(SNR, MSE_rect_show, '--b');
semilogy(SNR, MSE_cross_show, '--g');
semilogy(SNR, MSE_optimal_show, '--r');

% fprintf("before optimization: CRB: %.5e, MSE: %.5e \n ", CRB_normal(2), MSE_normal_show(2));
% fprintf("before optimization: CRB: %.5e, MSE: %.5e \n ", CRB_optimal(2), MSE_optimal_show(2));

% end