clc;
clear;
close all;

objectParameter1 = defineObject(70, 10, [0.4, 0.44124], 1, -4);
objectParameter2 = defineObject(120,-10, [0.3,0.12332], 1, -4);
objectParameter3 = defineObject(30, -5, [-0.3,0.3321], 1, -4);
objectParameter4 = defineObject(150, 5, [-0.2,0.22134], 1, -5);

[Tx, Rx] = uniform_arrays_2D(4, 4); % without wavelength

% Tx = opt_Tx;
% Rx = opt_Rx;

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

[targetList, range_doppler_fig, range_ux_fig, range_uy_fig] = signalProcessing(rawData4, radarParameter);
toc

fprintf("range\t\tvelocity\tux\t\tuy\n");
for i = 1 : size(targetList, 1)
    fprintf("%.5f\t\t%.5f\t\t%.10f\t\t%.10f\n", targetList(i,:));
end

%%
range_ux_fig = range_ux_fig/max(range_ux_fig(:));
range_ux_fig = flip(range_ux_fig, 1);

range_uy_fig = range_uy_fig/max(range_uy_fig(:));
range_uy_fig = flip(range_uy_fig, 1);

range_doppler_fig = range_doppler_fig/max(range_doppler_fig(:));
range_doppler_fig = flip(range_doppler_fig, 1);
range_doppler_fig = flip(range_doppler_fig, 2);

figure;
plot_range_doppler(range_doppler_fig);

figure;
plot_range_DOA(range_ux_fig, "ux");

figure;
plot_range_DOA(range_uy_fig, "uy");