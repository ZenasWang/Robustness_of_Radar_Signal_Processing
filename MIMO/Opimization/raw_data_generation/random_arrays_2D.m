function [Tx, Rx] = random_arrays_2D(Lmax, N_Tx, N_Rx)
% a function to generate random array
% return Tx and Rx array
Tx = Lmax * rand(N_Tx, 2);
Rx = Lmax * rand(N_Rx, 2);
Tx(1, :) = [0, 0];

end