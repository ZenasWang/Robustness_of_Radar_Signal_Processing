clc;
clear;

objectParameter1 = defineObject(100, 10, [0.2222,0.3333], 1, 8);
objectParameter2 = defineObject(100.67, 11, [0.1111,0.2222], 1, 8);
objectParameter3 = defineObject(101.34, 13, [0.1111,0.2222], 1, 8);
objectParameter4 = defineObject(102.01, 13, [0.1111,0.2222], 1, 8);

[Tx, Rx] = random_arrays_2D(30, 20, 4, false); % without wavelength
% Tx = opm_P_unit(1:20, :);
% Rx = opm_P_unit(21:24, :);
radarParameter = defineRadar(77e9, 224e6, 20.36e6, 256, 238, Tx, Rx);
% radarParameter.P = opm_P;

tic
rawData1 = signalGenerator_SO(radarParameter, objectParameter1);

rawData2 = signalGenerator_SO(radarParameter, objectParameter1) ...
         + signalGenerator_SO(radarParameter, objectParameter2);

rawData3 = signalGenerator_SO(radarParameter, objectParameter1) ...
         + signalGenerator_SO(radarParameter, objectParameter2) ...
         + signalGenerator_SO(radarParameter, objectParameter3) ;
     
rawData4 = signalGenerator_SO(radarParameter, objectParameter1) ...
         + signalGenerator_SO(radarParameter, objectParameter2) ...
         + signalGenerator_SO(radarParameter, objectParameter3) ...
         + signalGenerator_SO(radarParameter, objectParameter4);
     
[targetList] = signalProcessing(rawData4, radarParameter);
toc

fprintf("range\t\tvelocity\tux\t\tuy\n");
for i = 1 : size(targetList, 1)
    fprintf("%.2f\t\t%.2f\t\t%.4f\t\t%.4f\n", targetList(i,:));
end