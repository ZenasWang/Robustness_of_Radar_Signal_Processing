function [ angle ] = DOAEstimator( arrayResponse,radarParameters, r0_hat, vr_hat)
%BARTLETT_ANGLEESTI: Calculate the Bartlett Spectrum as the Correlation of
%the phase shifted channels outputs and estimate the DOA by Maximizing the
%Bartlett Spectrum
% - arrayResponse   := signal after pulse compression
% - radarParameters := The defines Radar Modulation Parameters
% - angle            := The estimated DOA
%      
%
% angle estimation
% az = -2*pi : (pi/100): pi*2;
% el = -pi*2 : (pi/100): pi*2;
ux = -1 : 0.01 : 1;
uy = 0 : 0.01 : 1;
tpn = (0 : radarParameters.N_Tx - 1) * radarParameters.T_pn;
E = -2*pi /radarParameters.c0 * [2 * kron(radarParameters.f0', ones([radarParameters.N_Rx,1])),...
                               + 2 * kron(radarParameters.f0' .* tpn', ones([radarParameters.N_Rx,1])),...
                               + kron(radarParameters.f0', ones([radarParameters.N_Rx,1])) .* radarParameters.P];

for x = 1 : length(ux)%(az)
  for y = 1 : length(uy)%(el)
    % ideal angle vector
%     u_ideal = [sin(az(azcount))*cos(el(elcount)); sin(el(elcount)); cos(el(elcount))*cos(az(azcount))];
    u_ideal = [ux(x); uy(y); sqrt(1 - ux(x)^2 + uy(y) ^2)];
% ideal Signal
    X_ideal = exp(1j * E * [r0_hat; vr_hat; u_ideal]);
    % Bartlett Spectrum
%     B(azcount,elcount) = ((abs(arrayResponse' * X_ideal)).^2);
    B(x,y) = abs(arrayResponse' * X_ideal).^2;
%     L(azcount,elcount) = abs(exp(-1j*(E * [r0_hat; vr_hat;0.433; 0.5;0.75])).' * exp(1j*(E * [r0_hat; vr_hat; u_ideal]))).^2;
  end
end
surf(B)
% [~,maxInd]= max(abs(B(:)));
% [az_ind,el_ind] = ind2sub(size(B),maxInd);
[az_ind,el_ind] = find(B == max(B(:)));
% angle = [az(az_ind)/pi*180, el(el_ind)/pi*180];
angle = [ux(az_ind), uy(el_ind)];
end

