function [CRB_2D] = CRB_only_for_DOA(P, radarParameter, objectParameter)
% function to return the CRB of given radarparameters and objectParameters
% return a 2D matrix for unkown parameter vector [ux uy]

% define some parameters 
SNR_dB = objectParameter.SNR;
SNR_linear = 10^(SNR_dB/10);
c = radarParameter.c0;
signal_power = objectParameter.A^2;
f0 = radarParameter.f0;
N_pn = radarParameter.N_pn;
noise_power = signal_power / SNR_linear;

% calculate CRB
Var = cov(P, 1);
CRB_2D = noise_power * c^2 /(f0^2 * 8 * pi^2 * N_pn * signal_power) * inv(Var);

% CRB_2D = trace(CRB);
% CRB_2D = [1,1] * diagCRB;
end