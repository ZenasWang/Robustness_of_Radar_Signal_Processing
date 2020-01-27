function radarParameter = defineRadar(carrier_frequence , bandwidth, sample_frequence,...
                                      N_chirps, N_samples, Tx_positions, Rx_positions)
% a function to configrate TDM radar parameters and 
% return radarParameter struct

% carrier_frequence := defined carrier frequence
% bandwidth := defined sweep bandwidth
% sample_frequency := defined frequency of sampling
% N_chirps := defined number of chirps for every transmition
% N_samples := defined number of sampels for every chirps
% Tx/Px_position: positions of transmission and reception antennas,
%                 unit : 0.5 * wavelength

% output: radarParameter contains every parameter needed to 
% describe a radar
% radarParameter.P is the positon of virtual antennas
% unit is mm !!!

% Tx numbers
radarParameter.N_Tx = size(Tx_positions, 1) * 2;
% Rx numbers
radarParameter.N_Rx = size(Rx_positions, 1);

% TDM radar Transmitter antennas for decoupling
radarParameter.Tx = [Tx_positions; flip(Tx_positions, 1)];
radarParameter.Rx = Rx_positions;

% antenna position number
radarParameter.N_pn = radarParameter.N_Tx * radarParameter.N_Rx;   
% chirp number per pulse
radarParameter.N_chirp = N_chirps;  
% sample number per chirp
radarParameter.N_sample = N_samples;
% sample duration
radarParameter.T_sample = 1 / sample_frequence;
% chirp duration
radarParameter.T_chirp = radarParameter.T_sample * radarParameter.N_sample;
% duration per antenna
radarParameter.T_pn = radarParameter.T_chirp * radarParameter.N_chirp;  
% full time
radarParameter.T_full = radarParameter.T_pn * radarParameter.N_Tx;    
% bandwidth
radarParameter.B = bandwidth;
% chirp rate
radarParameter.ramp = radarParameter.B / radarParameter.T_chirp; 
% light speed
radarParameter.c0 = physconst('LightSpeed');

% for FDM radar
% carrier frequency
% radarParameter.f0(1:radarParameter.N_Tx) = carrier_frequence;
% wavelength
% radarParameter.wavelength = radarParameter.c0 ./ kron(radarParameter.f0', ...
%                                     ones([radarParameter.N_Rx, 1]));

% for TDM radar
% carrier frequency
radarParameter.f0 = carrier_frequence;
% wavelength
radarParameter.wavelength = radarParameter.c0 / radarParameter.f0;  

% build antenna positions with unit of 1/2 lamda
radarParameter.P = radarParameter.wavelength/2 ...
                    .* (kron(radarParameter.Tx, ones([radarParameter.N_Rx, 1])) + ...
                    kron(ones([radarParameter.N_Tx, 1]), radarParameter.Rx));
                
end