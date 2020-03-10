function [] = plot_ambi_func_2D(Tx, Rx, radarParameter)

ux = -1 : 0.001 : 1;
uy = -0.5 : 0.001 : 0.5;
Ambi = zeros(numel(uy), numel(ux));

P = to_virture_arrays(Tx, Rx, radarParameter);

for i = 1 : size(ux,2)
    for j = 1 : size(uy,2)
        Ambi(j,i) = ambiguity_func(ux(i), uy(j), P, radarParameter);
    end
end

Ambi = Ambi/ max(Ambi(:));
Ambi = flip(Ambi, 1);

% imagesc(Ambi)
% colormap("jet")

% surf(ux,uy, Ambi)
% axis('equal');

contourf(ux,uy, Ambi, 100, 'linestyle', 'none');

axis('equal');
xlabel('ux')
ylabel('uy')
c_r=colorbar;
ylabel(c_r,'beta')
end