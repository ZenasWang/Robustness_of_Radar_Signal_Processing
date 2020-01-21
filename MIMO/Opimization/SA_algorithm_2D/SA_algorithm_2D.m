%%
clear
clc

Lmax = 40; % max positon of antennas, unit by wavelength/2
N_Tx = 20;
N_Rx = 4;
[Tx, Rx] = random_arrays_2D(Lmax, N_Tx, N_Rx, false);
radarParameter = defineRadar(94e9, 3e9, 10e6, 160, 1000, Tx, Rx);
objectParameter = defineObject(15, 2, [0.5126,0.3323], 1, -5);
N_pn = radarParameter.N_pn;   % number of all virtual antenna

%%
% penalty term coefficient，should be tuned
beta = 5e-3;

% X initialized by random choise one in N antennas in 0-L
N = 1000;
% N = floor(100*N_pn*2/L);
Xs = zeros(N_pn, 2, N);
% generate N initialized antenna

parfor i = 1: N
    Xs(:,:,i) = random_genrate_arrays(Lmax, N_Tx, N_Rx, radarParameter);
end
X0_ind = randi(N);
X = Xs(:, :, X0_ind);

% one way to initialize temperature
E = zeros(N, 1);
parfor i = 1: N
    E(i) = fitness_func_2D(Xs(:,:,i), radarParameter, objectParameter);
end
T0 = mean(E) - 1.5 * std(E,1);
% T0 = 0.002;
%%
% another to initialize temperature
%p = exp(deltaE / T0), 
% p = 0.75;
% deltaE = mean(E) + std(E,1);
% T0 = deltaE / log(p);

count = 1;
% initializa parameters
% lowest_t = 0.000001;      % lowest temperature
temperature = T0 * exp(-0.07 * count);     % initial tempotature
iter = 10;             % iteration
% iter = floor(100*N_pn*2/L);
full_iter = 50;
% T_rate = 0.95;         % temperature changing rate 

% 适应度方程结果
enegy(count) = fitness_func_2D(X, radarParameter, objectParameter);  
CRB(count) = trace(CRB_func_2D(X, radarParameter, objectParameter));
sll(count) = get_SLL_2D_use_image(X, radarParameter, objectParameter);
fprintf("iteration: 1, CRB: %.5e, sll:%.2f \n", CRB(1), sll(1));

% while temperature > lowest_t  % 停止迭代温度
for count = 2 : full_iter
    for n  = 1 : iter
%         fprintf("itering \n");
        % 变异
        new_X = get_new_1(L, N_pn);  
        % new_X = get_new(X, L, N_pn);
%         if max(sqrt(sum(new_X.^2, 2))) <= L && min(new_X(:)) >= 0
%             fprintf("selected \n");
        enegy1 = fitness_func_2D_1(X, radarParameter, objectParameter, beta);
        enegy2 = fitness_func_2D_1(new_X, radarParameter, objectParameter, beta); 
        delta_e = enegy2 - enegy1;
        % 变异后优化方程值变小了
        if delta_e < 0
            X = new_X;
        else
            % 没变小则有一定概率进行更换
            if rand() < exp(-delta_e/temperature)  
%                     fprintf("dE = %.2e, probability of change: %.2f \n", delta_e, exp(-delta_e/temperature))
%                     fprintf("changed")
                X = new_X;
            end
        end
%         end
    end  
%     count = count + 1;
    enegy(count) = fitness_func_2D_1(X, radarParameter, objectParameter, beta);
    CRB(count) = trace(CRB_func_2D(X, radarParameter, objectParameter));
    sll(count) = get_SLL_2D_use_image(X, radarParameter, objectParameter);
    temperature = T0 * exp(-0.07*count);
%     fprintf("temperature : %f, iteration: %d, CRB: %.5e, sll:%.2f \n", temperature, count, CRB(count), sll(count));
    fprintf("iteration: %d, T: %.5e, CRB: %.5e, sll:%.2f \n", count, temperature, CRB(count), sll(count));
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
    Ambi_mat(x,y) = ambiguity_func(ux(x), uy(y), opt_P, radarParameter, objectParameter);
  end
end
Ambi_mat = Ambi_mat / max(Ambi_mat(:));
subplot(4, 1, 2:4);
surf(ux,uy, Ambi_mat);
axis('equal');