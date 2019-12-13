function [CRB_2D] = CRB_func_2D(P, radarParameter, objectParameter)
% function to return the CRB of given radarparameters and objectParameters
% return a 2D matrix for unkown parameter vector [ux uy]

% example data
% radarParameter = defineRadar(94e9 , 3e9, 10e6,...
%                            160, 1000, [0,0,0], [0,0,0;0,1,0;1,0,0;1,1,0;2,0,0;0,2,0;2,1,0;1,2,0;2,2,0]);
% objectParameter = defineObject(15, 2, [0,0,0], 1, -1);
% P = radarParameter.P;

% planar antenna array
P = P(:,1:2);

% define some parameters 
N_sample = radarParameter.N_sample;
N_chirp = radarParameter.N_chirp;
SNR_dB = objectParameter.SNR;
SNR_linear = 10^(SNR_dB/10) * (N_sample * N_chirp);
c = radarParameter.c0;
signal_power = (N_sample * N_chirp * objectParameter.A) ^2;
f0 = radarParameter.f0';
N_pn = radarParameter.N_pn;
noise_power = signal_power / SNR_linear;


% calculate CRB
Var = cov(P, 1); % .* kron(f0, ones([radarParameter.N_Rx, 3]))
CRB_2D = noise_power * c^2 ./(f0(1)^2 * 8 * pi^2 * N_pn * signal_power .* Var);
% CRB_2D = trace(CRB);
% CRB_2D = [1,1,1] * diagCRB;
end