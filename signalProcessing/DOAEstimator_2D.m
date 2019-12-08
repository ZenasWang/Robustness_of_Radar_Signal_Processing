function [ angle ] = DOAEstimator_2D( arrayResponse,radarParameter, r0_hat, vr_hat)
%BARTLETT_ANGLEESTI: Calculate the Bartlett Spectrum as the Correlation of
%the phase shifted channels outputs and estimate the DOA by Maximizing the
%Bartlett Spectrum
% - arrayResponse    := signal after pulse compression
% - radarParameters  := The defines Radar Modulation Parameters
% - angle            := The estimated DOA
%      
%
% angle estimation
ux = -1 : 0.001 : 1;
uy = -1 : 0.001 : 1;
tpn = (0 : radarParameter.N_Tx - 1) * radarParameter.T_pn;
E = -2*pi /radarParameter.c0 * [2 * kron(radarParameter.f0', ones([radarParameter.N_Rx,1])),...
                               + 2 * kron(radarParameter.f0' .* tpn', ones([radarParameter.N_Rx,1])),...
                               + kron(radarParameter.f0', ones([radarParameter.N_Rx,1])) .* radarParameter.P];
                           
B = zeros(length(ux), length(ux));
for x = 1 : length(ux)      %(az)
  for y = 1 : length(uy)    %(el)
    % ideal angle vector
    u_ideal = [ux(x); uy(y); sqrt(1 - ux(x)^2 + uy(y) ^2)];
    % ideal Signal
    X_ideal = exp(1j * E * [r0_hat; vr_hat; u_ideal]);
    % Bartlett Spectrum
    B(x,y) = abs(arrayResponse' * X_ideal).^2;
  end
end
[ux_ind,uy_ind] = find(B == max(B(:)));
ux_ind = ux_ind(1);
uy_ind = uy_ind(1);

% interpretation for 2D DOA
ux_fine = ux(ux_ind-3) : 0.0001 : ux(ux_ind+3);
uy_fine = uy(uy_ind-3) : 0.0001 : uy(uy_ind+3);
[X, Y] = meshgrid((ux(ux_ind-3):0.001 :ux(ux_ind+3))', uy(uy_ind-3) : 0.001 : uy(uy_ind+3));
[Xq, Yq]= meshgrid(ux_fine', uy_fine);
V = B((ux_ind-3:ux_ind+3), (uy_ind-3:uy_ind+3));
Vb = interp2(X,Y,V,Xq,Yq,'cubic');  % 三次方插值
[ux_fine_ind,uy_fine_ind] = find(Vb == max(Vb(:)));
% surf(Vb)
% angle = [ux(ux_ind(1)), uy(uy_ind(1))];
angle = [ux_fine(ux_fine_ind), uy_fine(uy_fine_ind)];
end

