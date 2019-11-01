function radarParameter = defineRadar()
%define the configration module parameters
radarParameter.N_pn = 8;       % pulse number
radarParameter.N_chirp = 1000;  % chirp number per pulse
radarParameter.N_sample = 20;  % sample number per chirp

radarParameter.T_full = 8e-3;                     % full time
radarParameter.T_pn = radarParameter.T_full /radarParameter. N_pn;            % duration per pulse
radarParameter.T_chirp = radarParameter.T_pn / radarParameter.N_chirp;        % chirp duration
radarParameter.T_sample = radarParameter.T_chirp / radarParameter.N_sample;   % sample duration

radarParameter.B = 1e9;                        %bandwidth
radarParameter.ramp = radarParameter.B / radarParameter.T_chirp;             % chirp rate
radarParameter.f0(1: N_pn) = 70e9;              % carrier frequency

% antenna_configuration
radarParameter.P_Tx(1: N_pn) = 0;
radarParameter.P_Rx(1: N_pn) = 10;
radarParameter.A = 10; 
radarParameter.c0 = 299792458;

end

