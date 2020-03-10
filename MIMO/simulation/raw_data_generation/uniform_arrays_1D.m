function [Tx, Rx] = uniform_arrays_1D(N_Tx, N_Rx)
% a function to generate uniform array
% return Tx and Rx array

% - N_Tx    := numbers of trasmission antennas
% - N_Rx    := numbers of reception antennas

% - Tx      := builed position of trasmission antennas
% - Rx      := builed position of reception antennas

array = 0: 1: N_Tx + N_Rx - 1;
Tx = zeros(N_Tx, 2);
Rx = zeros(N_Rx, 2);
Tx(:, 1) = array(1:N_Tx)';
Rx(:, 1) = array(N_Tx+1:N_Tx + N_Rx)';
end