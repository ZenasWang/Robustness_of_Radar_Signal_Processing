function [MSE_r0, MSE_vr] = monte_carlo(radarParameter, objectParameter)
MSE_r0 = 0;
MSE_vr = 0;
parfor i = 1 :1000
    radarSignal_1 = signalGenerator_SO(radarParameter, objectParameter);
    [targetList, ~] = signalProcessing( radarSignal_1, radarParameter );
    MSE_r0 = MSE_r0 + (targetList(1)- objectParameter.r0)^2;
    MSE_vr = MSE_vr + (targetList(2)- objectParameter.vr)^2;
end
MSE_r0 = 1/1000 * MSE_r0;
MSE_vr = 1/1000 * MSE_vr;
end

