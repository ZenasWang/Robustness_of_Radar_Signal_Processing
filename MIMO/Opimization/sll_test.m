clc;
clear;

Lmax = 80; % max positon of antennas, unit by wavelength/2
N_Tx = 20;
N_Rx = 4;
[Tx_positions, Rx_positions] = random_arrays_2D(Lmax, N_Tx, N_Rx, false);
radarParameter = defineRadar(94e9, 3e9, 10e6, 160, 1000, Tx_positions, Rx_positions);
objectParameter = defineObject(15, 2, [0.5126,0.3323], 1, -5);
E = zeros(1, 100);
parfor i = 1:100
    P = random_genrate_arrays(Lmax, N_Tx, N_Rx, radarParameter);
    E(i) = get_SLL_2D_use_image(radarParameter.P, radarParameter, objectParameter);
end