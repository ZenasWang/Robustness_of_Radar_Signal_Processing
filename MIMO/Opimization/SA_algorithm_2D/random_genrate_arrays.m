function [P] = random_genrate_arrays(Lmax, N_Tx, N_Rx, min_interval, radarParameter)
% a function to generate random array with a fixed pisition(0,0) for Tx
% return Tx and Rx array

Tx = Lmax * rand(N_Tx, 2);
Tx(1,:) = [0, 0];
Rx = Lmax * rand(N_Rx, 2);
Y = [Tx;Rx];

while(min_distance_1D(Y(:,1)) <= min_interval/(radarParameter.wavelength/2) || ...
      min_distance_1D(Y(:,2)) <= min_interval/(radarParameter.wavelength/2))
    Tx = Lmax * rand(N_Tx, 2);
    Tx(1,:) = [0, 0];
    Rx = Lmax * rand(N_Rx, 2);
    Y = [Tx;Rx];
end

Tx = [Tx; flip(Tx, 1)];
N_Tx = 2 * N_Tx;
P = radarParameter.wavelength/2 .* (kron(Tx, ones([N_Rx, 1])) + ...
                    kron(ones([N_Tx, 1]), Rx));
end