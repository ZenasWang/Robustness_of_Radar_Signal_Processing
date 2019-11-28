% function [MSE_r0, MSE_vr,MSE_ux] = monte_carlo(radarParameter, objectParameter)
radarParameter_normal = defineRadar(94e9 , 3e9, 10e6,...
                           160, 1000, [0,0,0], [0,0,0;1,0,0;2.5,0,0;3,0,0;4,0,0;5,0,0;6,0,0;7,0,0]);
lamda = radarParameter_normal.c0 / radarParameter_normal.f0(1);
radarParameter_optimal = defineRadar(94e9 , 3e9, 10e6,...
                           160, 1000, [0,0,0], opm_P./(lamda/2));
objectParameter = defineObject(15, 2, [0,0,0], 1, 8);
radarSignal_normal = signalGenerator_SO(radarParameter_normal, objectParameter);
[targetList_normal] = signalProcessing(radarSignal_normal, radarParameter_normal);

MSE_r0_normal = 0;
MSE_vr_normal = 0;
MSE_ux_normal = 0;
MSE_r0_optimal = 0;
MSE_vr_optimal = 0;
MSE_ux_optimal = 0;

parfor i = 1 :1000
    radarSignal_normal = signalGenerator_SO(radarParameter_normal, objectParameter);
    [targetList_normal] = signalProcessing(radarSignal_normal, radarParameter_normal);
    MSE_r0_normal = MSE_r0_normal + (targetList_normal(1) - objectParameter.r0)^2;
    MSE_vr_normal = MSE_vr_normal + (targetList_normal(2) - objectParameter.vr)^2;
    MSE_ux_normal = MSE_ux_normal + (targetList_normal(3) - objectParameter.u(1))^2;
    radarSignal_optimal = signalGenerator_SO(radarParameter_optimal, objectParameter);
    [targetList_optimal] = signalProcessing(radarSignal_optimal, radarParameter_optimal);
    MSE_r0_optimal = MSE_r0_optimal + (targetList_optimal(1) - objectParameter.r0)^2;
    MSE_vr_optimal = MSE_vr_optimal + (targetList_optimal(2) - objectParameter.vr)^2;
    MSE_ux_optimal = MSE_ux_optimal + (targetList_optimal(3) - objectParameter.u(1))^2;
end

MSE_r0_normal = 1/1000 * MSE_r0_normal;
MSE_vr_normal = 1/1000 * MSE_vr_normal;
MSE_ux_normal = 1/1000 * MSE_ux_normal;
MSE_r0_optimal = 1/1000 * MSE_r0_optimal;
MSE_vr_optimal = 1/1000 * MSE_vr_optimal;
MSE_ux_optimal = 1/1000 * MSE_ux_optimal;

MSE_ux_normal
MSE_ux_optimal
% end

