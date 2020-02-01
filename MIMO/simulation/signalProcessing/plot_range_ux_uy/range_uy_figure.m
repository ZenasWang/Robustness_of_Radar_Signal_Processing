function [norm_cost_func] = range_uy_figure(arrayResponse_2D, vr_hat, ux_hat, radarParameter)

tpn = [-radarParameter.N_Tx/2 : -1, 1 : radarParameter.N_Tx/2] * radarParameter.T_pn;

E = -2*pi /radarParameter.c0 * [2 * radarParameter.f0 * ones(radarParameter.N_pn, 1),...
                                2 * radarParameter.f0 * kron(tpn', ones([radarParameter.N_Rx,1])),...
                                radarParameter.f0 * radarParameter.P];

uy = -1 : 0.0028 : 1;
            
cost_func = zeros(size(arrayResponse_2D, 1), numel(uy));
    
for i = 1 : numel(uy)
    X_ideal = exp(1j * E * [0; vr_hat; ux_hat; uy(i)]);
    for k = 1 : size(arrayResponse_2D, 1)
        cost_func(k, i) = abs((arrayResponse_2D(k, :).')'* X_ideal).^2;
    end
end

norm_cost_func = cost_func / max(cost_func(:));

end