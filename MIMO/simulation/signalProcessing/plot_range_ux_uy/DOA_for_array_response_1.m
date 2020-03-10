function [ angle ] = DOA_for_array_response_1(arrayResponse, radarParameter)
E = -2*pi /radarParameter.c0 * radarParameter.f0 * radarParameter.P;

% angle estimation
ux = -0.5 : 0.01 : 0.5;
uy = 0 : 0.01 : 0.5;
cost_func = zeros(numel(ux), numel(uy));

for ux_idx = 1 : numel(ux)
    for uy_idx = 1 : numel(uy)
        X_ideal = exp(1j * E * [ux(ux_idx); uy(uy_idx)]);
        cost_func(ux_idx, uy_idx) = abs(arrayResponse' * X_ideal).^2;
    end
end

[ux_ind_max,uy_ind_max] = find(cost_func == max(cost_func(:)));
ux_ind_max = ux_ind_max(1);
uy_ind_max = uy_ind_max(1);

ux_estimate = ux(ux_ind_max);
uy_estimate = uy(uy_ind_max);

% contourf(uy, ux, cost_func, 100, 'linestyle', 'none');
% axis('equal');
% xlabel('ux')
% ylabel('uy')
% c_r=colorbar;
% ylabel(c_r,'beta')

interval = 0.01;

for i = 1 : 9
interval = interval/10;
ux = ux_estimate - 20*interval : interval : ux_estimate + 20*interval;
uy = uy_estimate - 20*interval : interval : uy_estimate + 20*interval;

cost_func = zeros(numel(ux), numel(uy));
for ux_idx = 1 : numel(ux)
    for uy_idx = 1 : numel(uy)
        X_ideal = exp(1j * E * [ux(ux_idx); uy(uy_idx)]);
        cost_func(ux_idx, uy_idx) = abs(arrayResponse' * X_ideal).^2;
    end
end
[ux_ind_max,uy_ind_max] = find(cost_func == max(cost_func(:)));
ux_ind_max = ux_ind_max(1);
uy_ind_max = uy_ind_max(1);

ux_estimate = ux(ux_ind_max);
uy_estimate = uy(uy_ind_max); 
end
angle = [ux_estimate, uy_estimate];
end