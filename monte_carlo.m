% function [MSE_r0, MSE_vr,MSE_ux] = monte_carlo(radarParameter, objectParameter)
clc
clear 
load('opt_antenna_2D.mat')
radarParameter_normal_1D = defineRadar(94e9 , 3e9, 10e6,...
                           160, 1000, [0,0,0], [0,0,0;1,0,0;2,0,0;3,0,0;4,0,0;5,0,0;6,0,0;7,0,0]);
                       
radarParameter_normal_2D = defineRadar(94e9 , 3e9, 10e6,...
                           160, 1000, [0,0,0], [0,0,0;1,0,0;0,1,0;1,1,0;0,2,0;2,0,0;2,1,0;1,2,0;2,2,0]);
                       
lamda = radarParameter_normal_2D.c0 / radarParameter_normal_2D.f0(1);
radarParameter_optimal = defineRadar(94e9 , 3e9, 10e6,...
                           160, 1000, [0,0,0], opm_P./(lamda/2));
                       
ux = 0.234;
uy = 0.654;
objectParameter = defineObject(15, 2, [ux,uy,sqrt(1-(ux^2 + uy^2))], 1, -15);

T = 1000;
targetList_normal = zeros(T, 5);
targetList_optimal = zeros(T, 5);
%%
parfor i = 1 : T
    radarSignal_normal = signalGenerator_SO(radarParameter_normal_2D, objectParameter);
    targetList_normal(i, :) = signalProcessing(radarSignal_normal, radarParameter_normal_2D);
%     MSE_r0_normal_mat(i) = targetList_normal(1);
%     MSE_vr_normal_mat(i) = targetList_normal(2);
%     MSE_ux_normal_mat(i) = targetList_normal(3);
%     MSE_uy_normal_mat(i) = targetList_normal(4);
    radarSignal_optimal = signalGenerator_SO(radarParameter_optimal, objectParameter);
    targetList_optimal(i, :) = signalProcessing(radarSignal_optimal, radarParameter_optimal);
%     MSE_r0_optimal_mat(i) = targetList_optimal(1);
%     MSE_vr_optimal_mat(i) = targetList_optimal(2);
%     MSE_ux_optimal_mat(i) = targetList_optimal(3);
%     MSE_uy_optimal_mat(i) = targetList_optimal(4);
end
%%
% MSE_r0_normal = 1/T * sum((MSE_r0_normal_mat).^2);
% MSE_vr_normal = 1/T * sum((MSE_vr_normal_mat).^2);
MSE_ux_normal = 1/T * sum((targetList_normal(:,3) - ux).^2);
MSE_uy_normal = 1/T * sum((targetList_normal(:,4) - uy).^2);
% MSE_r0_optimal = 1/T * sum((MSE_r0_optimal_mat).^2);
% MSE_vr_optimal = 1/T * sum((MSE_vr_optimal_mat).^2);
MSE_ux_optimal = 1/T * sum((targetList_optimal(:,3) - ux).^2);
MSE_uy_optimal = 1/T * sum((targetList_optimal(:,4) - uy).^2);

% MSE_r0_normal = 1/T * sum((MSE_r0_normal_mat - mean(MSE_r0_normal_mat)).^2);
% MSE_vr_normal = 1/T * sum((MSE_vr_normal_mat - mean(MSE_vr_normal_mat)).^2);
% MSE_ux_normal = 1/T * sum((MSE_ux_normal_mat - mean(MSE_ux_normal_mat)).^2);
% MSE_uy_normal = 1/T * sum((MSE_uy_normal_mat - mean(MSE_uy_normal_mat)).^2);
% MSE_r0_optimal = 1/T * sum((MSE_r0_optimal_mat - mean(MSE_r0_optimal_mat)).^2);
% MSE_vr_optimal = 1/T * sum((MSE_vr_optimal_mat - mean(MSE_vr_optimal_mat)).^2);
% MSE_ux_optimal = 1/T * sum((MSE_ux_optimal_mat - mean(MSE_ux_optimal_mat)).^2);
% MSE_uy_optimal = 1/T * sum((MSE_uy_optimal_mat - mean(MSE_uy_optimal_mat)).^2);

MSE_ux_normal
MSE_ux_optimal
MSE_uy_normal
MSE_uy_optimal

% CRB_normal = CRB_func_2D(radarParameter_normal_2D.P, radarParameter_normal_2D, objectParameter)
% CRB_optimal = CRB_func_2D(radarParameter_optimal.P, radarParameter_optimal, objectParameter)
% end

