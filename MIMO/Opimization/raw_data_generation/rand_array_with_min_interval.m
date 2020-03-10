function [Tx, Rx] = rand_array_with_min_interval(Lmax, N_Tx, N_Rx, min_interval)
% a function to generate random array with max positon (Lmax, Lmax)
% and keep the minimum distance, their unit are 1/2 wavelength
% return Tx and Rx and virtual array(unit mm).

[Tx, Rx] = random_arrays_with_max(Lmax, N_Tx, N_Rx);
Y = [Tx;Rx];

while(min_distance_1D(Y(:,1)) < min_interval|| ...
      min_distance_1D(Y(:,2)) < min_interval)
    [Tx, Rx] = random_arrays_with_max(Lmax, N_Tx, N_Rx);
    Y = [Tx;Rx];
end
end