% generate relavent data for test
clc;
clear;

objectParameter = defineObject(15, 2, [0.512,0.332], 1, -5);

[Tx_positions, Rx_positions] = uniform_arrays_2D(11, 20, 20);% without wavelength

radarParameter = defineRadar(94e9, 3e9, 10e6, 160, 1000, Tx_positions, Rx_positions);

rawData = signalGenerator_SO(radarParameter, objectParameter);