function signal = signalGenerator_SO(radarParameter, objectParameter) % input 
    tpn = 0 : T_pn: T_full - T_full / N_pn;
    k = 0 : N_chirp - 1; % in which chirp
    ns = 0 : N_sample - 1;   % in which sample
    
    % frequence of 
    fD = -2 * radarParameter.f0 * objectParameter.vr / radarParameter.c0;     % 1 x N_pn
    fR = -2 * radarParameter.ramp * objectParameter.r0 / radarParameter.c0;   %scalar

    for i = 1 : N_pn
        X(:, :, i) = A * exp(1j * 2 * pi * (-2 * radarParameter.f0(i) * r0 / c0))...
          * exp(1j * 2 * pi * (fD(i) * tpn(i)))... % scalar
          * exp(1j * 2 * pi * fR * ns' * radarParameter.T_sample)... % N_sample x 1
          * exp(1j * 2 * pi * fD(i) * k * radarParameter.T_chirp)... % 1 x N_T_chirp
          * exp(1j * 2 * pi * f0(i) / c0 * (radarParameter.P_Tx(i)...
                                    + radarParameter.P_Rx(i)) * objectParameter.u);
    end

    n = objectParameter.sigma * randn(radarParameter.N_sample, ...
                                        radarParameter.N_chirp, radarParameter.N_pn);
    signal = X + n;
end