%%
clear
clc

N_Tx = 20;
N_Rx = 4;
SNR = -5;
min_interval = 0.1e-3;  % unit:m

[Tx, Rx] = random_arrays_2D(51, N_Tx, N_Rx, false);

radarParameter = defineRadar(77e9, 224e6, 20.36e6, 256, 238, Tx, Rx);
objectParameter = defineObject(15, 2, [0, 0], 1, SNR);
N_pn = radarParameter.N_pn;   % number of all virtual antenna

% number of parameter to optimization
num_para = N_Tx + N_Rx - 2;

% lagest distance between antennas, 10 cm, unit 1/2 wavelength
Lmax = floor(0.1/(radarParameter.wavelength/2));

% minimal interval by unit 1/2 wavelength
min_interval_unit = min_interval/(radarParameter.wavelength/2);

[P, Tx, Rx] = random_genrate_arrays(Lmax, N_Tx, N_Rx, min_interval, radarParameter);
% Tx = opt_Tx;
% Rx = opt_Rx;
% P = opt_P;

% initial tempotature
T0 = 1e-12;

% initializa parameters
temperature = T0; 

% iteration
iter = 100;

% iter = floor(100*N_pn*2/L) = 630;
full_iter = 400;

% initialized fitness function
enegy_0 = fitness_func_2D(P, radarParameter, objectParameter);  
CRB_0 = trace(CRB_func_2D(P, radarParameter, objectParameter));
sll_0 = get_SLL_2D_use_image(P, radarParameter);
fprintf("iteration: 0, CRB: %.5e, sll:%.2f \n", CRB_0, sll_0);

enegy = zeros(1, full_iter);
CRB = zeros(1, full_iter);
sll = zeros(1, full_iter);

sigma = Lmax^2 / (N_Tx+N_Rx-2)^2;

%%
% while temperature > lowest_t  % 停止迭代温度
for count = 1 : full_iter
    new_sigma = 1/log10(count+10) * sigma .* exp(2 * (2 * num_para)^(-1/2) * randn(N_Tx + N_Rx, 2));
    for n = 1 : iter
        % generate new antenna
        [new_X, new_Tx, new_Rx] = new_arrays(Tx, Rx, Lmax, min_interval, radarParameter, new_sigma);
        
%             fprintf("selected \n");
        enegy1 = fitness_func_2D(P, radarParameter, objectParameter);
        enegy2 = fitness_func_2D(new_X, radarParameter, objectParameter); 
        delta_e = enegy2 - enegy1;
        % 变异后优化方程值变小了
        if delta_e < 0
            P = new_X;
            Tx = new_Tx;
            Rx = new_Rx;
        else
            % 没变小则有一定概率进行更换,差值越小更换的几率越大
            if rand() < exp(-delta_e/temperature)
%                     fprintf("dE = %.2e, probability of change: %.2f \n", delta_e, exp(-delta_e/temperature))
%                     fprintf("changed")
                P = new_X;
                Tx = new_Tx;
                Rx = new_Rx;                
                
            end
        end
    end
%     count = count + 1;
    enegy(count) = fitness_func_2D(P, radarParameter, objectParameter);
    CRB(count) = trace(CRB_func_2D(P, radarParameter, objectParameter));
    sll(count) = get_SLL_2D_use_image(P, radarParameter);
    temperature = T0 * exp(-0.01*count);
%     fprintf("temperature : %f, iteration: %d, CRB: %.5e, sll:%.2f \n", temperature, count, CRB(count), sll(count));
    fprintf("iteration: %d, CRB: %.5e, sll:%.2f \n", count, CRB(count), sll(count));
end
opt_P = P;
opt_Tx = Tx;
opt_Rx = Rx;

%%
% save("../SA_results/SA_results_20x4_SNR-5.mat");

%%
figure(1);
plot(1:full_iter, [CRB], 'b')

figure(2);
plot_ambi_func_2D(opt_P, radarParameter);