function [P, Tx, Rx] = random_genrate_arrays(Lmax, N_Tx, N_Rx, min_interval, radarParameter)
% a function to generate random array with a fixed pisition(0,0) for Tx
% return Tx and Rx array

Tx = Lmax * rand(N_Tx, 2);
Tx(1,:) = [0, 0];
Rx = Lmax * rand(N_Rx, 2);
Rx(end,:) = [Lmax, Lmax];
Y = [Tx;Rx];

while(min_distance_1D(Y(:,1)) < min_interval/(radarParameter.wavelength/2) || ...
      min_distance_1D(Y(:,2)) < min_interval/(radarParameter.wavelength/2))
    Tx = Lmax * rand(N_Tx, 2);
    Tx(1,:) = [0, 0];
    Rx = Lmax * rand(N_Rx, 2);
    Rx(end,:) = [Lmax, Lmax];
    Y = [Tx;Rx];
end

P = to_virture_arrays(Tx, Rx, radarParameter);
end