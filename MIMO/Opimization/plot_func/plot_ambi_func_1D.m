function [] = plot_ambi_func_1D(opm_P, radarParameter, objectParameter)

ux = -1 : 0.01 : 1;
for i = 1: size(ux,2)
    Ambi(i) = ambiguity_func(ux(i), 0, opm_P, radarParameter, objectParameter);
end
Ambi = Ambi/ max(Ambi(:));
plot(ux, Ambi)
end