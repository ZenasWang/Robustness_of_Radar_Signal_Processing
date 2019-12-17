function [ angle ] = DOAEstimator_1D( arrayResponse,radarParameter, r0_hat, vr_hat)
%BARTLETT_ANGLEESTI: Calculate the Bartlett Spectrum as the Correlation of
%the phase shifted channels outputs and estimate the DOA by Maximizing the
%Bartlett Spectrum
% - arrayResponse    := signal after pulse compression
% - radarParameters  := The defines Radar Modulation Parameters
% - angle            := The estimated DOA
%      
%
% angle estimation

ux = -1 : 0.00001 : 1;
uy = 0;
tpn = (0 : radarParameter.N_Tx - 1) * radarParameter.T_pn;
E = -2*pi /radarParameter.c0 * [2 * kron(radarParameter.f0', ones([radarParameter.N_Rx,1])),...
                               2 * kron(radarParameter.f0' .* tpn', ones([radarParameter.N_Rx,1])),...
                               kron(radarParameter.f0', ones([radarParameter.N_Rx,3])) .* radarParameter.P];

E0 = -2*pi /radarParameter.c0 * kron(radarParameter.f0', ones([radarParameter.N_Rx,3])) .* radarParameter.P;
for x = 1 : length(ux)%(az)
  for y = 1 : length(uy)%(el)
    % ideal angle vector
    u_ideal = [ux(x); uy(y); sqrt(1 - ux(x)^2 + uy(y) ^2)];
    % ideal Signal
    X_ideal = exp(1j * E * [r0_hat; vr_hat; u_ideal]);
    X_ideal0 = exp(1j * E0 * u_ideal);
    % Bartlett Spectrum
    B(x,y) = abs(arrayResponse' * X_ideal0).^2;
  end
end

[ux_ind,uy_ind] = find(B == max(B(:)));
ux_ind = ux_ind(1);
uy_ind = uy_ind(1);

% % interpretation for 1D DOA
% X = ux(ux_ind-3 :ux_ind+3);
% ux_fine = ux(ux_ind-3) : 0.0001 : ux(ux_ind+3);
% V = B(ux_ind-3 : ux_ind+3);
% Vb = interp1(X', V, ux_fine', 'spline');
% [ux_fine_ind,uy_fine_ind] = find(Vb == max(Vb(:)));

% Parab approx Interpolation
parabPar = [1, -1, 1;1, 0, 0;1, 1, 1] \ (B([ux_ind-1,ux_ind,ux_ind+1],1));
deltaPos = -parabPar(2) / (2*parabPar(3));
max_Amp = [1,deltaPos,deltaPos^2]*parabPar;
realmaxpos = (ux_ind -1 + deltaPos);
% ux_real = ux(ux_ind - 1) + deltaPos*0.00001
ux_real = (realmaxpos-1) / (length(ux)-1) * 2 - 1;

% with interpolation
angle = [ux_real, uy(uy_ind(1))];

% no interpolation
% angle = [ux(ux_ind), uy(uy_ind)];

% angle = [ux_fine(ux_fine_ind), uy(uy_fine_ind)];
end

