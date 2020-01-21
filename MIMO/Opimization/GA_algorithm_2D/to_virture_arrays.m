function [P] = to_virture_arrays(Tx, Rx, radarParameter)
% a function to generate vertual antenna position

Tx = [Tx; flip(Tx, 1)];
N_Tx = size(Tx, 1);
N_Rx = size(Rx, 1);
P = radarParameter.wavelength/2 .* (kron(Tx, ones([N_Rx, 1])) + ...
                    kron(ones([N_Tx, 1]), Rx));
                
end