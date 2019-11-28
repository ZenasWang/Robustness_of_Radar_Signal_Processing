function [diagCRB] = CRB_func(P, radarParameter, objectParameter)
SNR = objectParameter.SNR;
c = radarParameter.c0;
signal_power = objectParameter.A;   % A^2
N_sample = radarParameter.N_sample;
N_chirp = radarParameter.N_chirp;
f0 = radarParameter.f0';
N_pn = radarParameter.N_pn;
% sigma^2
noise_power = signal_power / (10^(SNR/10));

% for i = 1 : N_pn
%     for j = 1 : 3
%         P_mat(i,j) = P(3*(i-1)+j) * radarParameter.c0 / f0(1);
%     end
% end

variance = cov(P,1);
Varx = cov(P .* kron(f0, ones([radarParameter.N_Rx, 3])), 1);
Varx = Varx(1,1);
CRB = noise_power * c^2 / (8 * pi^2 * signal_power)...
      /Varx;
% diagCRB = sum(diag(CRB));
diagCRB = CRB;
end