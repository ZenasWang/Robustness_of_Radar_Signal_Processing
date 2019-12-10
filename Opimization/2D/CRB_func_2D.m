function [CRB_2D] = CRB_func_2D(P, radarParameter, objectParameter)

% example data
% radarParameter = defineRadar(94e9 , 3e9, 10e6,...
%                            160, 1000, [0,0,0], [0,0,0;0,1,0;1,0,0;1,1,0;2,0,0;0,2,0;2,1,0;1,2,0;2,2,0]);
% objectParameter = defineObject(15, 2, [0,0,0], 1, -1);
% P = radarParameter.P;

% Pz = 1 - sqrt(P(:,1).^2 + P(:,2).^2);
% P(:,3) = Pz;
P = P(:,1:2);
% define some parameters 
SNR_dB = objectParameter.SNR;
SNR_linear = 10^(SNR_dB/10);
c = radarParameter.c0;
signal_power = objectParameter.A;
N_sample = radarParameter.N_sample;
N_chirp = radarParameter.N_chirp;
f0 = radarParameter.f0';
N_pn = radarParameter.N_pn;
noise_power = signal_power / SNR_linear;
% .* kron(f0, ones([radarParameter.N_Rx, 3]))
% calculate CRB
Var = cov(P, 1);
CRB = noise_power * c^2 ./(f0(1)^2 * radarParameter.N_pn * radarParameter.N_Rx...
                            * 8 * pi^2 * signal_power .* Var);
CRB_2D = trace(CRB);
% CRB_2D = [1,1,1] * diagCRB;
end