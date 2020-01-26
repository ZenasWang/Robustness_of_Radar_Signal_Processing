function [Tx, Rx] = uniform_arrays_1D(Lmax, N_Tx, N_Rx, P_plot)
% a function to generate uniform array
% return Tx and Rx array

% - Lmax    := largest position of arrays, unit by 0.5*wavelength
% - N_Tx    := numbers of trasmission antennas
% - N_Rx    := numbers of reception antennas
% - P_plot  := if plot the posotion

% - Tx      := builed position of trasmission antennas
% - Rx      := builed position of reception antennas

array = linspace(0, Lmax, N_Tx + N_Rx);
Tx = zeros(N_Tx, 2);
Rx = zeros(N_Rx, 2);
Tx(:, 1) = array(1:N_Tx)';
Rx(:, 1) = array(N_Tx+1:N_Tx + N_Rx)';

if P_plot
    plot_array_pos(Lmax, Tx, Rx);
end
end