function signal = signalGenerator_SO(radarParameter, objectParameter) % input 
    tpn = 0 : radarParameter.T_pn: radarParameter.T_full - radarParameter.T_full / radarParameter.N_pn;
    k = 0 : radarParameter.N_chirp - 1; % in which chirp
    ns = 0 : radarParameter.N_sample - 1;   % in which sample
    
    % phaseshift because of vr
    fD = -2 * radarParameter.f0 * objectParameter.vr / radarParameter.c0;     % 1 x N_pn
    % phaseshift because of r0
    fR = -2 * radarParameter.ramp * objectParameter.r0 / radarParameter.c0;   %scalar
    for i = 1 : radarParameter.N_pn
        X(:, :, i) = radarParameter.A ...
          * exp(1j * 2 * pi * (-2 * radarParameter.f0(i) * objectParameter.r0 / radarParameter.c0))...
          * exp(1j * 2 * pi * (fD(i) * tpn(i)))... % scalar
          * exp(1j * 2 * pi * fR * ns' * radarParameter.T_sample)... % N_sample x 1
          * exp(1j * 2 * pi * fD(i) * k * radarParameter.T_chirp)... % 1 x N_T_chirp
          * exp(1j * 2 * pi * radarParameter.f0(i) / radarParameter.c0... 
                           * radarParameter.P(i, :) * objectParameter.u');
    end   
    n = objectParameter.sigma * randn(radarParameter.N_sample, ...
                                      radarParameter.N_chirp, radarParameter.N_pn);
    signal = X + n;
end