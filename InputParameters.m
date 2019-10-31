
clear all
%define the configration module parameters
N_pn = 8;       % pulse number
N_chirp = 1000;  % chirp number per pulse
N_sample = 20;  % sample number per chirp

T_full = 8e-3;                     % full time
T_pn = T_full / N_pn;            % duration per pulse
T_chirp = T_pn / N_chirp;        % chirp duration
T_sample = T_chirp / N_sample;   % sample duration

B = 1e9;                        %bandwidth
ramp = B / T_chirp;             % chirp rate
f0(1: N_pn) = 70e9;              % carrier frequency

% antenna_configuration
P_Tx(1: N_pn) = 0;
P_Rx(1: N_pn) = 10;
A = 10; 
c0 = 3e8;

%define the scenatio modeule parameters
r0 = 100;
vr = 0;
sigma = 6;
u = pi / 180 * 15;
