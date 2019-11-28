function [ angle ] = DOAEstimator( arrayResponse,radarParameter, r0_hat, vr_hat)
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
ux = -1 : 0.00001 : 1;
uy = 0;
tpn = (0 : radarParameter.N_Tx - 1) * radarParameter.T_pn;
E = -2*pi /radarParameter.c0 * [2 * kron(radarParameter.f0', ones([radarParameter.N_Rx,1])),...
                               + 2 * kron(radarParameter.f0' .* tpn', ones([radarParameter.N_Rx,1])),...
                               + kron(radarParameter.f0', ones([radarParameter.N_Rx,1])) .* radarParameter.P];

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
%     L(x,y) = abs(exp(1j*(E * [r0_hat; vr_hat;0;0;0]))' * exp(1j*(E * [r0_hat; vr_hat; u_ideal]))).^2;
  end
end
[ux_ind,uy_ind] = find(B == max(B(:)));
% hold on
% lamda = radarParameter.c0 / radarParameter.f0(1);
% % distance between each antenna for 均匀分布
% d = lamda/2 * 2;
% u_3db = 0.891 * lamda/2/(radarParameter.N_pn)/d;
% % X_ideal_0 = exp(1j * E * [r0_hat; vr_hat; ux(ux_ind) + u_3db/2; uy(uy_ind) + u_3db/2;...
% %     sqrt(1 - (ux(ux_ind) + u_3db/2)^2 - (ux(ux_ind) + u_3db)/2)]);
% % % plot3(ux(ux_ind) + u_3db/2, uy(uy_ind) + u_3db/2, abs(arrayResponse' * X_ideal_0).^2, 'o')
% a = abs(sum(exp(1j*(E * [r0_hat; vr_hat;...
%     ux(ux_ind(1)) + u_3db/2; uy(uy_ind(1)) + u_3db/2;...
%     sqrt(1 - (ux(ux_ind(1)) + u_3db/2)^2 - (uy(uy_ind(1)) + u_3db/2)^2)])))).^2
% b = L(ux_ind(1),uy_ind(1))/2
% angle = [az(az_ind)/pi*180, el(el_ind)/pi*180];
angle = [ux(ux_ind(1)), uy(uy_ind(1))];
end

