function [ambi_func] = ambiguity_func(ux, uy, P, radarParameter)
% AMBIGUITY_FUNC
% use ambiguity function to set constraint during optimization
% constrain SLL lower than 1/2 main lobe

E = -2*pi /radarParameter.c0 * radarParameter.f0 * P;           
ambi_func = abs((exp(1j*(E * [0;0])))'...
              * exp(1j*(E * [ux;uy]))).^2;
end