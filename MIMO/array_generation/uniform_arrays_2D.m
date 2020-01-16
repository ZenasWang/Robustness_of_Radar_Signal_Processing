function [Tx, Rx] = uniform_arrays_2D(Lmax, N_Tx, N_Rx, P_plot)
% a function to generate uniform array
% return Tx and Rx array

interval_Tx = Lmax / (N_Tx / 2 + 1);
interval_Rx = Lmax / (N_Rx / 2 + 1);
Tx = zeros(N_Tx, 2);
Rx = zeros(N_Rx, 2);
Tx(1:N_Tx/2, 1) = 0;
Tx(N_Tx/2+1:N_Tx, 1) = Lmax;
Tx(:, 2) = repmat((interval_Tx : interval_Tx : Lmax-interval_Tx)', 2, 1);

Rx(1:N_Rx/2, 2) = 0;
Rx(N_Tx/2+1:N_Rx, 2) = Lmax;
Rx(:, 1) = repmat((interval_Rx : interval_Rx : Lmax-interval_Rx)', 2, 1);

if P_plot
    plot_array_pos(Lmax, Tx, Rx);
end
end