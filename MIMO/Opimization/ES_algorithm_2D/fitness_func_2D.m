function [value] = fitness_func_2D(P, radarParameter, objectParameter)

CRB_2D = CRB_func_2D(P, radarParameter, objectParameter);
CRB = trace(CRB_2D);
SLL = get_SLL_2D_use_image(P, radarParameter);
if SLL <= 0.5
    beta = 0;
else
    beta = 1;
end
value = (1 - beta) * CRB + beta * SLL;
end