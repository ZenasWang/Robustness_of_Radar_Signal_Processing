function [] = plot_ambi_func_2D(opm_P, radarParameter)

ux = -1 : 0.01 : 1;
uy = -1 : 0.01 : 1;
Ambi = zeros(numel(ux), numel(uy));
for i = 1 : size(ux,2)
    for j = 1 : size(uy,2)
        Ambi(i,j) = ambiguity_func(ux(i), uy(j), opm_P, radarParameter);
    end
end
Ambi = Ambi/ max(Ambi(:));
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