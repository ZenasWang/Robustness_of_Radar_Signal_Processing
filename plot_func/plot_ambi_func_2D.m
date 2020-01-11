function [] = plot_ambi_func_2D(opm_P, radarParameter, objectParameter)

ux = -1 : 0.01 : 1;
uy = -1 : 0.01 : 1;
for i = 1 : size(ux,2)
    for j = 1 : size(uy,2)
        Ambi(i,j) = ambiguity_func(ux(i), uy(j), opm_P, radarParameter, objectParameter);
    end
end
Ambi = Ambi/ max(Ambi(:));
% imagesc(Ambi)
% colormap("jet")
surf(ux,uy, Ambi)
axis('equal')
end