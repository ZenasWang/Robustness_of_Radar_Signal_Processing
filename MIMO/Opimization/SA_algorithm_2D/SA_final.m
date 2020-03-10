%%
clear
clc

N_Tx = 4;
N_Rx = 4;
SNR = -5;
min_interval = 0.1e-3;  % unit:m

[Tx, Rx] = uniform_array_4x4();

radarParameter = defineRadar(77e9, 224e6, 20.36e6, 256, 238, Tx, Rx);
objectParameter = defineObject(15, 2, [0, 0], 1, SNR);

% number of parameter to optimization
num_para = N_Tx + N_Rx - 1;

% lagest distance between antennas, 10 cm, unit 1/2 wavelength
Lmax_unit = 0.1/(radarParameter.wavelength/2);

% minimal interval by unit 1/2 wavelength
min_interval_unit = min_interval/(radarParameter.wavelength/2);

P = to_virture_arrays(Tx, Rx, radarParameter);

% initial tempotature
T0 = 1e-3;

% initializa parameters
temperature = T0; 

% iteration
iter = 500;

% iter = floor(100*N_pn*2/L) = 630;
full_iter = 650;

% initialized fitness function
energy_0 = fitness_func_2D(P, radarParameter, objectParameter);  
CRB_0 = trace(CRB_only_for_DOA(P, radarParameter, objectParameter));
sll_0 = get_SLL_2D_use_image(P, radarParameter);
fprintf("iteration: 0, CRB: %.5e, sll:%.2f \n", CRB_0, sll_0);

energy = zeros(1, full_iter);
CRB = zeros(1, full_iter);
sll = zeros(1, full_iter);

% mutation strength
sigma = Lmax_unit^2 / (N_Tx+N_Rx-1)^2;

%%
energy1 = energy_0;
% while temperature > lowest_t  % 停止迭代温度
for count = 1 : full_iter
    new_sigma = 1/log10(count+10) * sigma .* exp(2 * (2 * num_para)^(-1/2) * randn(N_Tx + N_Rx, 2));
    for n = 1 : iter
        % generate new antenna
        [new_P, new_Tx, new_Rx] = new_arrays(Tx, Rx, Lmax_unit, min_interval_unit, radarParameter, new_sigma);
        energy2 = fitness_func_2D(new_P, radarParameter, objectParameter); 
        delta_e = energy2 - energy1;
        % 变异后优化方程值变小了
        if delta_e < 0
            P = new_P;
            Tx = new_Tx;
            Rx = new_Rx;
            energy1 = energy2;
        else
            % 没变小则有一定概率进行更换,差值越小更换的几率越大
            if rand() < exp(-delta_e/temperature)
                P = new_P;
                Tx = new_Tx;
                Rx = new_Rx;     
                energy1 = energy2;
            end
        end
    end
    energy(count) = fitness_func_2D(P, radarParameter, objectParameter);
    CRB(count) = trace(CRB_only_for_DOA(P, radarParameter, objectParameter));
    sll(count) = get_SLL_2D_use_image(P, radarParameter);
    temperature = T0 * exp(-0.01*count);
    fprintf("iteration: %d, CRB: %.5e, sll:%.2f \n", count, CRB(count), sll(count));
end

opt_P = P;
opt_Tx = Tx;
opt_Rx = Rx;
%%
save("./SA_results/SA_results_4x4_SNR-5.mat");

%%
figure(1);
plot(1:full_iter, [CRB], 'b')

figure(3);
plot(1:full_iter, [sll], 'g')

figure(2);
plot_ambi_func_2D(opt_Tx, opt_Rx, radarParameter);