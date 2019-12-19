clc;
clear;
objectParameter = defineObject(15, 2, [0.5126,0.3323], 1, -5);

[Tx_positions, Rx_positions] = uniform_arrays_2D(11, 20, 20);% without wavelength
radarParameter = defineRadar(94e9, 3e9, 10e6, 160, 1000, Tx_positions, Rx_positions);
tic
rawData = signalGenerator_SO(radarParameter, objectParameter);
[targetList] = signalProcessing(rawData, radarParameter);
toc
fprintf("range\t\tvelocity\tux\t\tuy\n");
for i = 1 : size(targetList, 1)
    fprintf("%.5f\t%.5f\t\t%.5f\t\t%.5f\n", targetList(i,:));
end