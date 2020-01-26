function [] = plot_v_ux(P, radarParameter, objectParameter)

ux = -1 : 0.01 : 1;
v = -30 : 0.8 : 30;

Ambi = zeros(numel(v), numel(ux));
for i = 1 : numel(ux)
    for k = 1 : numel(v)
        Ambi(k,i) = ambiguity_func(ux(i), 0, v(k), P, radarParameter, objectParameter);
    end
end
Ambi = Ambi/ max(Ambi(:));
% imagesc(Ambi)
% colormap("jet")

% surf(Ambi)
% axis('equal');
[X, Y] = meshgrid(ux, v);

contourf(X, Y, Ambi, 100, 'linestyle', 'none');
% axis('equal');
xlabel('ux')
ylabel('v')
% xlim([-1, 1])
% ylim([-4, 4])
xticks('auto')
yticks('auto')
c_r=colorbar;
ylabel(c_r,'beta') 
end

function [ambi_func] = ambiguity_func(ux, uy, v, P, radarParameter, objectParameter)
% full version
tpn = (0 : radarParameter.N_Tx - 1) * radarParameter.T_pn;
E = -2*pi /radarParameter.c0 * [2 * radarParameter.f0 * ones(radarParameter.N_pn, 1),...
                                2 * radarParameter.f0 * kron(tpn', ones([radarParameter.N_Rx,1])),...
                                radarParameter.f0 * P];
ambi_func = abs((exp(1j*(E * [objectParameter.r0;...
                             objectParameter.vr;...
                             0;0])))'...
              * exp(1j*(E * [objectParameter.r0; v;...
                             ux;uy]))).^2;
end