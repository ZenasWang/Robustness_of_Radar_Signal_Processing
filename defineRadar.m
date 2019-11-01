function radarParameter = defineRadar(carrier_frequence, bandwidth, total_time,...
                                        N_chirps, N_samples, Ante_Position)
%define the configration module parameters

radarParameter.P = Ante_Position;   % Ante Positions
               
radarParameter.N_pn = length(radarParameter.P);       % antenna position number

radarParameter.N_chirp = N_chirps;  % chirp number per pulse

radarParameter.N_sample = N_samples;  % sample number per chirp

radarParameter.T_full = total_time;    % full time

radarParameter.T_pn = radarParameter.T_full /radarParameter. N_pn;  % duration per pulse

radarParameter.T_chirp = radarParameter.T_pn / radarParameter.N_chirp; % chirp duration

radarParameter.T_sample = radarParameter.T_chirp / radarParameter.N_sample; % sample duration

radarParameter.B = bandwidth; %bandwidth
radarParameter.ramp = radarParameter.B / radarParameter.T_chirp; % chirp rate

if length(carrier_frequence) == 1
    radarParameter.f0(1: radarParameter.N_pn) = carrier_frequence;% carrier frequency
else
    radarParameter.f0 = carrier_frequence;
end

% antenna_configuration
radarParameter.A = 10; 
radarParameter.c0 = 299792458;

end

