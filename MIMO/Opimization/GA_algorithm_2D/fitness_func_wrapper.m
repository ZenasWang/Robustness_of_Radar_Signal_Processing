function [value] = fitness_func_wrapper(x, radarParameter, objectParameter)
% a wrapper to map x to fitness function

[Tx, Rx] = disassembleX(x, radarParameter);
P = to_virture_arrays(Tx, Rx, radarParameter);
value = fitness_func_2D(P, radarParameter, objectParameter);

end