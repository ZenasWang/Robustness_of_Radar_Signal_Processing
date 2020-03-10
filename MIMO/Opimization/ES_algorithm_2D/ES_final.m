clear;
clc;
close all;

N_Tx = 4;
N_Rx = 4;
SNR = -5;
min_interval = 0.1e-3;  % unit:m

[Tx, Rx] = uniform_array_4x4();

radarParameter = defineRadar(77e9, 224e6, 20.36e6, 256, 238, Tx, Rx);
objectParameter = defineObject(15, 2, [0, 0], 1, SNR);

% lagest distance between antennas, 10 cm, unit 1/2 wavelength
Lmax_unit = 0.1/(radarParameter.wavelength/2);

% relative min interval
min_interval_unit = min_interval/(radarParameter.wavelength/2);

% first population number
N = 1000;

% X 为 N_pn x 2 x N
% if initialized by random choise in 0-L
X = zeros(N_Tx + N_Rx, 2, N);
i = 1;

while i <= N
    [Tx, Rx] = random_arrays_2D(Lmax_unit, N_Tx, N_Rx);
    temp = [Tx; Rx];
    if(min_distance_1D(temp(:,1)) >= min_interval_unit ...
       && min_distance_1D(temp(:,2)) >= min_interval_unit)
        X(:,:,i) = temp;
        i = i + 1;
    end
end

% initialize variance strength
sigma = Lmax_unit^2 / (N_Tx+N_Rx-1)^2;

% cross ratio
u = 0.5;

% iteration bumbers
T = 150;

% track maximum fitness for every iteration
maxf = Inf;
CRB0 = trace(CRB_only_for_DOA(radarParameter.P, radarParameter, objectParameter));
sll0 = get_SLL_2D_use_image(radarParameter.P, radarParameter);
fprintf("iteration: 0, CRB: %.5e, sll:%.2f \n", CRB0, sll0);

max_f = zeros(1, T);
sll = zeros(1, T);
mean_f = zeros(1, T);

for t = 1 : T
   num_children=1;
   offspring = zeros(N_Tx + N_Rx, 2, 7 * N);
   while num_children <= 7 * N
       pos = randi(N, 1, 2); % 1 * N
       % random choose two antenna posoiton as parents
       pa1 = X(:, :, pos(1));
       pa2 = X(:, :, pos(2));
       % generate child
       child = u * pa1 + (1-u) * pa2;
       % variance will be change with the increase of iteration
       new_sigma = sigma .* exp(2 * (2 * (N_Tx+N_Rx-1))^(-1/2) * randn(N_Tx+N_Rx-1, 2));
       % children value changed by variance
       Y = child + sqrt([[0,0];new_sigma]) .* [[0,0];randn(N_Tx+N_Rx-1, 2)];
       % gaurentee the largest position of antannas are smaller than L
       if(max(Y(:)) <= Lmax_unit && min(Y(:)) >= 0 && ...
           min_distance_1D(Y(:,1)) >= min_interval_unit && ...
           min_distance_1D(Y(:,2)) >= min_interval_unit)
           % if meet the condition, save child value and go to next child
           offspring(:,:,num_children) = Y;
           num_children = num_children + 1;
       end
   end
   U = offspring; % a matrix of 7N child antenna
   % 这里是(µ,λ)策略
   % u,λ选择策略: 从新生成的λ个体中选择 ,建议λ/μ = 7
   % μ/λ是压力比，其越大选择压力越大。
   % u + λ策略改为 U = [offspring, X]
   eva = zeros(1, size(U,3));
   parfor i = 1: size(U,3)
       temp = U(:, :, i);   % N_pn x 3
       temp_P = to_virture_arrays(temp(1:N_Tx, :), temp(N_Tx+1:end, :), radarParameter);
       eva(i) = fitness_func_2D(temp_P, radarParameter, objectParameter);   %把子代的70个个体适应度方程写出来
   end
%    fprintf("successfully evoluted\n")
   % m_eval是排序的适应度值，从小到大，I是对应的适应值原来的下标
   [m_eval,I] = sort(eva);
   I1 = I(1: N); % 从7*N子代中选出最小的N个的适应度下标行向量
   X = U(:,:,I1); % 把取出来的最小的下标代入，得到7*N中最好的N个个体
   % 比较最大适应度与maxf记录值，更新maxf,同时记录x1,x2值
   if m_eval(1) < maxf
       maxf = m_eval(1);
       opt_Tx_Rx = U(:,:,I(1));
       opt_P = to_virture_arrays(opt_Tx_Rx(1:N_Tx, :), opt_Tx_Rx(N_Tx+1:end, :), radarParameter);
   end
   
   max_f(t) = trace(CRB_only_for_DOA(opt_P, radarParameter, objectParameter));
   sll(t) = get_SLL_2D_use_image(opt_P, radarParameter);
      fprintf("iteration: %d, CRB: %.5e, sll:%.2f \n", t, max_f(t), sll(t));
   mean_f(t) = mean(eva(I1)); % 计算每代平均适应度
end

opt_Tx = opt_Tx_Rx(1:N_Tx, :);
opt_Rx = opt_Tx_Rx(N_Tx+1:end, :);

%%
save("./ES_results/ES_results_4x4_SNR-5.mat");

%%
figure(1);
plot(1:100, max_f(1:100), 'b');
figure(2);
plot(1:100, sll(1:100), 'g')
figure(3);
plot_ambi_func_2D(opt_Tx, opt_Rx, radarParameter);