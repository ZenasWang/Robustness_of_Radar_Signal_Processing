function [ angle ] = DOA_for_array_response(arrayResponse, radarParameter)
% Maximum likelihood estimation for DOA, use cost function directly
% return estimated [ux, uy]

% - arrayResponse    := signal after pulse compression
% - r0_hat           := the estimated range
% - vr_hat           := the estimated speed
% - radarParameters  := the defined Radar Modulation Parameters

% angle estimation
ux = -0.5 : 0.01 : 0.5;
uy = 0 : 0.01 : 0.5;

E = -2*pi /radarParameter.c0 * radarParameter.f0 * radarParameter.P;

u_array = [kron(ones(numel(uy), 1), ux'), kron(uy', ones(numel(ux), 1))];
cost_func = zeros(1, size(u_array,1));

for i = 1 : size(u_array, 1)
    X_ideal = exp(1j * E * u_array(i, :)');
    % Bartlett Spectrum
    cost_func(i) = abs(arrayResponse' * X_ideal).^2;
end

cost_func_mat = reshape(cost_func, numel(ux), numel(uy));

[ux_ind,uy_ind] = find(cost_func_mat == max(cost_func_mat(:)));
ux_ind = ux_ind(1);
uy_ind = uy_ind(1);

interval = 0.01;

for n = 1 : 8
interval = interval/10;
ux = ux(ux_ind) - 20*interval : interval : ux(ux_ind) + 20*interval;    
uy = uy(uy_ind) - 20*interval : interval : uy(uy_ind) + 20*interval;

u_array = [kron(ones(numel(uy), 1), ux'), kron(uy', ones(numel(ux), 1))];
cost_func = zeros(1, size(u_array, 1));
for i = 1 : size(u_array, 1)
    X_ideal = exp(1j * E * u_array(i, :)');
    % Bartlett Spectrum
    cost_func(i) = abs(arrayResponse' * X_ideal).^2;
end

cost_func_mat = reshape(cost_func, numel(ux), numel(uy));
[ux_ind,uy_ind] = find(cost_func_mat == max(cost_func_mat(:)));
ux_ind = ux_ind(1);
uy_ind = uy_ind(1);
end

angle = [ux(ux_ind), uy(uy_ind)];
end