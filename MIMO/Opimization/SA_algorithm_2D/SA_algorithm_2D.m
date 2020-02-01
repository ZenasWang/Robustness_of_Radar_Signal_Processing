%%
clear
clc

N_Tx = 20;
N_Rx = 4;
SNR = -5;
min_interval = 0.1e-3;  % unit:m

[Tx, Rx] = random_arrays_2D(31, N_Tx, N_Rx, false);

radarParameter = defineRadar(77e9, 224e6, 20.36e6, 256, 238, Tx, Rx);
objectParameter = defineObject(15, 2, [0, 0], 1, SNR);
N_pn = radarParameter.N_pn;   % number of all virtual antenna
% lagest distance between antennas, 10 cm
Lmax = floor(0.1/(radarParameter.wavelength/2));
% unit 1/2 wavelength

% % X initialized by random choise one in N antennas in 0-L
% N = 1000;
% 
% % N = floor(100*N_pn*2/L);
% Xs = zeros(N_pn, 2, N);
% % generate N initialized antenna
% 
% parfor i = 1: N
%     Xs(:,:,i) = random_genrate_arrays(Lmax, N_Tx, N_Rx, min_interval, radarParameter);
% end

% X0_ind = randi(N);
% X = Xs(:, :, X0_ind);

X = random_genrate_arrays(Lmax, N_Tx, N_Rx, min_interval, radarParameter);
% % one way to initialize temperature
% E = zeros(1, N);
% parfor i = 1: N
%     E(i) = fitness_func_2D(Xs(:,:,i), radarParameter, objectParameter);
% end

% T0 = 0.3 * (mean(E(E < 0.5)) - 1.5 * std(E(E < 0.5), 1));
T0 = 5e-12;
% T0 = 0.002;
%%
% another to initialize temperature
%p = exp(deltaE / T0), 
% p = 0.75;
% deltaE = mean(E) + std(E,1);
% T0 = - deltaE / log(p);

count = 1;

% initializa parameters
temperature = T0 * exp(-0.07 * count);% initial tempotature
iter = 5000;             % iteration
% iter = floor(100*N_pn*2/L) = 630;
full_iter = 35;

% initialized fitness function
enegy(count) = fitness_func_2D(X, radarParameter, objectParameter);  
CRB(count) = trace(CRB_func_2D(X, radarParameter, objectParameter));
sll(count) = get_SLL_2D_use_image(X, radarParameter);
fprintf("iteration: 1, CRB: %.5e, sll:%.2f \n", CRB(1), sll(1));

% while temperature > lowest_t  % 停止迭代温度
for count = 2 : full_iter
    for n  = 1 : iter
        % generate new antenna
        new_X = random_genrate_arrays(Lmax, N_Tx, N_Rx, min_interval, radarParameter);
        
%             fprintf("selected \n");
        enegy1 = fitness_func_2D(X, radarParameter, objectParameter);
        enegy2 = fitness_func_2D(new_X, radarParameter, objectParameter); 
        delta_e = enegy2 - enegy1;
        % 变异后优化方程值变小了
        if delta_e < 0
            X = new_X;
        else
            % 没变小则有一定概率进行更换,差值越小更换的几率越大
            if rand() < exp(-delta_e/temperature)
%                     fprintf("dE = %.2e, probability of change: %.2f \n", delta_e, exp(-delta_e/temperature))
%                     fprintf("changed")
                X = new_X;
            end
        end
%         end
    end  
%     count = count + 1;
    enegy(count) = fitness_func_2D(X, radarParameter, objectParameter);
    CRB(count) = trace(CRB_func_2D(X, radarParameter, objectParameter));
    sll(count) = get_SLL_2D_use_image(X, radarParameter);
    temperature = T0 * exp(-0.07*count);
%     fprintf("temperature : %f, iteration: %d, CRB: %.5e, sll:%.2f \n", temperature, count, CRB(count), sll(count));
    fprintf("iteration: %d, CRB: %.5e, sll:%.2f \n", count, CRB(count), sll(count));
end
opt_P = X;
%%
figure;
subplot(4,1,1)
plot(1:count, CRB, 'b')

ux = -1 : 0.01 : 1;
uy = -1 : 0.01 : 1;
for x = 1 : length(ux)%(az)
  for y = 1 : length(uy)%(el = 0)
    Ambi_mat(x,y) = ambiguity_func(ux(x), uy(y), opt_P, radarParameter);
  end
end
Ambi_mat = Ambi_mat / max(Ambi_mat(:));
subplot(4, 1, 2:4);
surf(ux,uy, Ambi_mat);
axis('equal');