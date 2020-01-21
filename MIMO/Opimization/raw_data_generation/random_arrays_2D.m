function [Tx, Rx] = random_arrays_2D(Lmax, N_Tx, N_Rx, P_plot)
% a function to generate random array
% return Tx and Rx array

% - Lmax    := largest position of arrays, unit by 0.5*wavelength
% - N_Tx    := numbers of trasmission antennas
% - N_Rx    := numbers of reception antennas
% - P_plot  := if plot the posotion

% - Tx      := builed position of trasmission antennas
% - Rx      := builed position of reception antennas

Tx = Lmax * rand(N_Tx, 2);
Rx = Lmax * rand(N_Rx, 2);
Tx(1, :) = [0, 0];

if P_plot
    plot_array_pos(Lmax, Tx, Rx);
end
end