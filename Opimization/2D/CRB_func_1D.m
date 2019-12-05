function [diagCRB] = CRB_func_1D(P, radarParameter, objectParameter)
% radarParameter = defineRadar(94e9 , 3e9, 10e6,...
%                            160, 1000, [0,0,0], [0,0,0;1,0,0;2,0,0;3,0,0;4,0,0;5,0,0;6,0,0;7,0,0]);
% objectParameter = defineObject(15, 2, [0,0,0], 1, -1);
% P = radarParameter.P;

SNR = objectParameter.SNR;
c = radarParameter.c0;
signal_power = objectParameter.A;   % A^2
N_sample = radarParameter.N_sample;
N_chirp = radarParameter.N_chirp;
f0 = radarParameter.f0';
N_pn = radarParameter.N_pn;
noise_power = signal_power / (10^(SNR/10));

Var = cov(P .* kron(f0, ones([radarParameter.N_Rx, 3])), 1);
Varx = Var(1,1);
% E_P = mean(P .* kron(f0, ones([radarParameter.N_Rx, 3])));
% Var1 = 1/radarParameter.N_pn * (P.* kron(f0, ones([radarParameter.N_Rx, 3])) - E_P)' * (P.* kron(f0, ones([radarParameter.N_Rx, 3])) - E_P)
CRB = noise_power * c^2 /(signal_power * (8 * pi^2 * signal_power) * Varx);
% CRB1 = noise_power * c^2 / (8 * pi^2 * signal_power)/Var1(1,1)
diagCRB = CRB;
end