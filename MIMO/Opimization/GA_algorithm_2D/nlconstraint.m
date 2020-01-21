function [ c, ceq ] = nlconstraint( x, min_dis, radarParameter )

[Tx, Rx] = disassembleX(x, radarParameter);
Y = [Tx;Rx];
c(1) = min_dis/(radarParameter.wavelength/2) - min_distance_1D(Y(:,1));
c(2) = min_dis/(radarParameter.wavelength/2) - min_distance_1D(Y(:,2));
P = to_virture_arrays(Tx, Rx, radarParameter);
c(3) = get_SLL_2D_use_image(P, radarParameter) - 0.5; 
ceq = [];
end