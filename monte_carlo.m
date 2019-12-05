% function [MSE_r0, MSE_vr,MSE_ux] = monte_carlo(radarParameter, objectParameter)
radarParameter_normal = defineRadar(94e9 , 3e9, 10e6,...
                           160, 1000, [0,0,0], [0,0,0;1,0,0;2,0,0;3,0,0;4,0,0;5,0,0;6,0,0;7,0,0]);
lamda = radarParameter_normal.c0 / radarParameter_normal.f0(1);
radarParameter_optimal = defineRadar(94e9 , 3e9, 10e6,...
                           160, 1000, [0,0,0], opm_P./(lamda/2));
objectParameter = defineObject(15, 2, [0,0,0], 1, -5);

MSE_r0_normal_mat = [];
MSE_vr_normal_mat = [];
MSE_ux_normal_mat = [];
MSE_r0_optimal_mat = [];
MSE_vr_optimal_mat = [];
MSE_ux_optimal_mat = [];

T = 1;
parfor i = 1 : T
    radarSignal_normal = signalGenerator_SO(radarParameter_normal, objectParameter);
    [targetList_normal] = signalProcessing(radarSignal_normal, radarParameter_normal);
    MSE_r0_normal_mat(i) = targetList_normal(1);
    MSE_vr_normal_mat(i) = targetList_normal(2);
    MSE_ux_normal_mat(i) = targetList_normal(3);

    radarSignal_optimal = signalGenerator_SO(radarParameter_optimal, objectParameter);
    [targetList_optimal] = signalProcessing(radarSignal_optimal, radarParameter_optimal);
    MSE_r0_optimal_mat(i) = targetList_optimal(1);
    MSE_vr_optimal_mat(i) = targetList_optimal(2);
    MSE_ux_optimal_mat(i) = targetList_optimal(3);
end
% MSE_r0_normal = 1/T * sum((MSE_r0_normal_mat).^2);% - mean(MSE_r0_normal_mat)).^2);
% MSE_vr_normal = 1/T * sum((MSE_vr_normal_mat).^2);%  - mean(MSE_vr_normal_mat)).^2);
% MSE_ux_normal = 1/T * sum((MSE_ux_normal_mat).^2);%  - mean(MSE_ux_normal_mat)).^2);
% MSE_r0_optimal = 1/T * sum((MSE_r0_optimal_mat).^2);%  - mean(MSE_r0_optimal_mat)).^2);
% MSE_vr_optimal = 1/T * sum((MSE_vr_optimal_mat).^2);%  - mean(MSE_vr_optimal_mat)).^2);
% MSE_ux_optimal = 1/T * sum((MSE_ux_optimal_mat).^2);%  - mean(MSE_ux_optimal_mat)).^2);

MSE_r0_normal = 1/T * sum((MSE_r0_normal_mat - mean(MSE_r0_normal_mat)).^2);
MSE_vr_normal = 1/T * sum((MSE_vr_normal_mat - mean(MSE_vr_normal_mat)).^2);
MSE_ux_normal = 1/T * sum((MSE_ux_normal_mat - mean(MSE_ux_normal_mat)).^2);
MSE_r0_optimal = 1/T * sum((MSE_r0_optimal_mat - mean(MSE_r0_optimal_mat)).^2);
MSE_vr_optimal = 1/T * sum((MSE_vr_optimal_mat - mean(MSE_vr_optimal_mat)).^2);
MSE_ux_optimal = 1/T * sum((MSE_ux_optimal_mat - mean(MSE_ux_optimal_mat)).^2);

MSE_ux_normal
MSE_ux_optimal

CRB_x_normal = CRB_func_1D(radarParameter_normal.P, radarParameter_normal, objectParameter)
CRB_x_optimal = CRB_func_1D(radarParameter_optimal.P, radarParameter_optimal, objectParameter)
% end

