function [ angle ] = DOAEstimator_2D(arrayResponse, r0_hat, vr_hat, radarParameter)
% Maximum likelihood estimation for DOA, use cost function directly
% return estimated [ux, uy]

% - arrayResponse    := signal after pulse compression
% - r0_hat           := the estimated range
% - vr_hat           := the estimated speed
% - radarParameters  := the defined Radar Modulation Parameters

% angle estimation
ux = -1 : 0.001 : 1;
uy = 0 : 0.001 : 1/2;

tpn = [-radarParameter.N_Tx/2 : -1 1 : radarParameter.N_Tx/2] * radarParameter.T_pn;

E = -2*pi /radarParameter.c0 * [2 * radarParameter.f0 * ones(radarParameter.N_pn, 1),...
                                2 * radarParameter.f0 * kron(tpn', ones([radarParameter.N_Rx,1])),...
                                radarParameter.f0 * radarParameter.P];

% normally vectorize is faster, but it need more memory, 
% if I set uy to 0:0.001:1, it will exceed the maxmum memory
% but for the situation here, it is not faser than loop!!!!!!!
% it can used in ambiguity function to find sll, because in that situation 
% we don't need fine grid, just 0.01

% u_array = [kron(ones(numel(uy), 1), ux'), kron(uy', ones(numel(ux), 1))];                
% X_ideal_arr = exp(1j * E * [r0_hat * ones(size(u_array, 1), 1),...
%                             vr_hat * ones(size(u_array, 1), 1),...
%                             u_array]');                       
% cost_func = abs(arrayResponse' * X_ideal_arr).^2;
% cost_func_mat = reshape(cost_func, numel(ux), numel(uy));


% loop version
% cost_func_mat = zeros(length(ux), length(uy));
% for x = 1 : length(ux)      %(az)
%   for y = 1 : length(uy)    %(el)
%     % ideal Signal
%     X_ideal = exp(1j * E * [r0_hat; vr_hat; ux(x); uy(y)]);
%     % Bartlett Spectrum
%     cost_func_mat(x,y) = abs(arrayResponse' * X_ideal).^2;
%   end
% end

% more faster version, using parallel computation for one loop
u_array = [kron(ones(numel(uy), 1), ux'), kron(uy', ones(numel(ux), 1))];
cost_func = zeros(1, size(u_array,1));
for i = 1 : size(u_array, 1)
    X_ideal = exp(1j * E * [r0_hat; vr_hat; u_array(i, :)']);
    % Bartlett Spectrum
    cost_func(i) = abs(arrayResponse' * X_ideal).^2;
end

cost_func_mat = reshape(cost_func, numel(ux), numel(uy));

[ux_ind,uy_ind] = find(cost_func_mat == max(cost_func_mat(:)));
ux_ind = ux_ind(1);
uy_ind = uy_ind(1);

% interpretation for 2D DOA
ux_fine = ux(ux_ind-3) : 0.0001 : ux(ux_ind+3);
uy_fine = uy(uy_ind-3) : 0.0001 : uy(uy_ind+3);
[X, Y] = meshgrid((ux(ux_ind-3):0.001 :ux(ux_ind+3))', uy(uy_ind-3) : 0.001 : uy(uy_ind+3));
[Xq, Yq]= meshgrid(ux_fine', uy_fine);
V = cost_func_mat((ux_ind-3:ux_ind+3), (uy_ind-3:uy_ind+3));
Vb = interp2(X,Y,V,Xq,Yq,'cubic');    % 三次方插值
[ux_fine_ind,uy_fine_ind] = find(Vb == max(Vb(:)));

% angle = [ux(ux_ind), uy(uy_ind)];
angle = [ux_fine(ux_fine_ind), uy_fine(uy_fine_ind)];
end
