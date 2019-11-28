% not finished

f = @(P)CRB_func(P, radarParameter, object1);


Aeq = [1,zeros(1,11);0,1,zeros(1,10);0,0,1,zeros(1,9)];

[x] = ga(f,12,[],[],[],[],zeros(1,12), ones(1,12));
for i = 1 : radarParameter.N_pn
    for j = 1 : 3
        P(i,j) = x(3*(i-1)+j);
    end
end
   