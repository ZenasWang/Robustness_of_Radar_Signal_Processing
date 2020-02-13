function [CRB] = fitness_func_2D_GA(P, radarParameter, objectParameter)
% fitness function -- the trace of CRB matrix

CRB_2D = CRB_func_2D(P, radarParameter, objectParameter);
CRB = trace(CRB_2D);

end