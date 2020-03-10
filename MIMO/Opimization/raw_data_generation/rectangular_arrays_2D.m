function [Tx, Rx] = rectangular_arrays_2D(N_Tx, N_Rx)
% a function to generate uniform array
% return Tx and Rx array

% - N_Tx    := numbers of trasmission antennas
% - N_Rx    := numbers of reception antennas

% - Tx      := builed position of trasmission antennas
% - Rx      := builed position of reception antennas

Tx = zeros(N_Tx, 2);
Rx = zeros(N_Rx, 2);

Tx(1:N_Tx/2, 1) = 0;
Tx(N_Tx/2+1:N_Tx, 1) = N_Rx/2 + 1;
Tx(1:N_Tx/2, 2) = (1 : 1 : N_Tx/2)';
Tx(N_Tx/2+1:N_Tx, 2) = (1 : 1 : N_Tx/2)';

Rx(1:N_Rx/2, 2) = 0;
Rx(N_Rx/2+1:N_Rx, 2) = N_Tx/2 + 1;
Rx(1:N_Rx/2, 1) = (1 : 1 : N_Rx/2)';
Rx(N_Rx/2+1:N_Rx, 1) = (1 : 1 : N_Rx/2)';

end