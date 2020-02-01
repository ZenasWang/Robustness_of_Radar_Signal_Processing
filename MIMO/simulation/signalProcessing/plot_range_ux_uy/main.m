clc;
clear;

objectParameter1 = defineObject(70, 10, [0.4, 0.4], 1, 8);
objectParameter2 = defineObject(120, 10, [0.4,0.1], 1, 8);
objectParameter3 = defineObject(1, 10, [0.4,0.1], 1, 8);
objectParameter4 = defineObject(150, 13, [-0.2,0.2], 1, 8);

[Tx, Rx] = random_arrays_2D(30, 20, 4, false); % without wavelength

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
     
%%     
[targetList, range_doppler_fig, range_ux_fig, range_uy_fig] = new_signalProcessing(rawData4, radarParameter);
toc

fprintf("range\t\tvelocity\tux\t\tuy\n");
for i = 1 : size(targetList, 1)
    fprintf("%.2f\t\t%.2f\t\t%.4f\t\t%.4f\n", targetList(i,:));
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