% function [r0, vr, u1, u2, u3] = estimateDOA(pulse_compression, radarParameter)

ym = pulse_compression(1,:);
tpn = (0 : radarParameter.N_Tx - 1) * radarParameter.T_pn;
E = 2*pi /radarParameter.c0 * [-2 * kron(radarParameter.f0', ones([radarParameter.N_Rx,1])),...
                               -2 * kron(radarParameter.f0' .* tpn', ones([radarParameter.N_Rx,1])),...
                               - kron(radarParameter.f0', ones([radarParameter.N_Rx,1])) .* radarParameter.P];


min = Inf;
min_r0 = 0;
min_vr = -radarParameter.c0 / (4 * radarParameter.f0(1) * radarParameter.T_chirp);
min_alpha = 0;
min_beta = 0;
for r0 = 0 : 0.01 :  radarParameter.c0 * radarParameter.N_sample/ (2 * radarParameter.B)
   for vr = -4 : 0.01...
            : 4
       for alpha = 0 : pi / 100 : pi
           for beta = 0 : pi / 100 : pi
               L = norm(ym * exp(1j * E * [r0, vr, sin(alpha) / sqrt(1 + tan(beta) ^2),...
                        tan(beta) / sqrt(1 + tan(beta) ^2),...
                        cos(alpha) / sqrt(1 + tan(beta) ^2)]')) ^2;
               if L < min
                   min = L;
                   min_r0 = r0;
                   min_vr = vr;
                   min_alpha = alpha;
                   min_beta = beta;
               end
           end
       end
   end
end
r0 = min_r0;
vr = min_vr;
u1 = sin(min_alpha) / sqrt(1 + tan(min_beta) ^2);
u2 = tan(min_beta) / sqrt(1 + tan(min_beta) ^2);
u3 = cos(min_alpha) / sqrt(1 + tan(min_beta) ^2);
% end

