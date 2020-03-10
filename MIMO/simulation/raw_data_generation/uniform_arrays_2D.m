function [Tx, Rx] = uniform_arrays_2D(N_Tx, N_Rx)
% a function to generate uniform array
% return Tx and Rx array

% - N_Tx    := numbers of trasmission antennas
% - N_Rx    := numbers of reception antennas

% - Tx      := builed position of trasmission antennas, unit 0.5*wavelength
% - Rx      := builed position of reception antennas, unit 0.5*wavelength

Tx = zeros(N_Tx, 2);
Rx = zeros(N_Rx, 2);

Tx(1:N_Tx, 2) = [0: 1: floor(N_Tx/2)-1, (floor(N_Tx/2)+1): 1: N_Tx];
Rx(1:N_Rx, 1) = 0: 1: N_Rx-1;
Tx(:, 1) = floor(N_Rx/2);
Rx(:, 2) = floor(N_Tx/2);
end