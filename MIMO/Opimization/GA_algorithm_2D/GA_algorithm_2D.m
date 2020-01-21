clear;
clc;
close all;

N_Tx = 20;
N_Rx = 4;
SNR = -5;
min_dis = 0.1e-3;  % unit:m

N_sum = (N_Tx + N_Rx - 1) * 2;

[Tx, Rx] = random_arrays_2D(31, N_Tx, N_Rx, false);
radarParameter = defineRadar(94e9, 3e9, 10e6, 160, 1000, Tx, Rx);

objectParameter = defineObject(15, 2, [0, 0], 1, SNR);

N_pn = radarParameter.N_pn;   % number of all virtual antenna

% lagest distance between antennas, 10 cm
Lmax = floor(0.1/(radarParameter.wavelength/2));
% unit 1/2 wavelength

cfun = @(x) fitness_func_wrapper(x, radarParameter, objectParameter);
nl_confun = @(x) nlconstraint(x, min_dis, radarParameter);

% Constraints
A=[];
b=[];
Aeq = [];
beq = [];

% Bounds
lb = zeros(1, N_sum);
ub = Lmax * ones(1, N_sum);

% Optimization
options = optimoptions('ga', 'MutationFcn',@mutationadaptfeasible, ...
                     'PopulationSize',10, ...
                     'Generations', 150, ...
                     'CreationFcn',@gacreationlinearfeasible, ...
                     'TolFun',1e-13, ...
                     'TolCon',1e-8, ...
                     'Display','iter', ...
                     'PlotFcn',@gaplotbestf, ...
                     'UseParallel',true);

[p_opt, crb_opt, exitflag, output, final_population, final_scores] = ...
    ga(cfun, N_sum, A, b, Aeq, beq, lb, ub, nl_confun, options);

% save("ES_results_20x4_SNR-5.mat")