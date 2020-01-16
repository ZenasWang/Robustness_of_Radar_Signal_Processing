% generate relavent data for test
clc;
clear;

objectParameter = defineObject(15, 2, [0.512,0.332], 1, -5);

[Tx_positions, Rx_positions] = uniform_arrays_2D(11, 20, 20, true);% without wavelength

radarParameter = defineRadar(77e9, 224e6, 20.36e6, 256, 238, Tx_positions, Rx_positions);

rawData = signalGenerator_SO(radarParameter, objectParameter);