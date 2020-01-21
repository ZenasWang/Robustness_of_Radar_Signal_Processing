clear;
clc;
close all;

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

N = 10;  % first population number

% % X 为 N_pn x 3 x N
% % if initialized by random choise in 0-L
X = zeros(N_Tx + N_Rx, 2, N);
i = 1;
while i <= N
    [Tx, Rx] = random_arrays_2D(Lmax, N_Tx, N_Rx, false);
    temp = [Tx; Rx];
    if(min_distance_1D(temp(:,1)) >= min_interval/(radarParameter.wavelength/2) ...
            && min_distance_1D(temp(:,2)) >= min_interval/(radarParameter.wavelength/2))
        X(:,:,i) = temp;
        i = i + 1;
    end
end

% initialize variance strength
sigma = Lmax^2 / (N_Tx + N_Rx)^2;

% cross ratio
u = 0.5;
% iteration bumbers
T = 120;

% track maximum fitness for every iteration
maxf = Inf;
CRB0 = trace(CRB_func_2D(radarParameter.P, radarParameter, objectParameter));
sll0 = get_SLL_2D_use_image(radarParameter.P, radarParameter);
fprintf("iteration: 0, CRB: %.5e, sll:%.2f \n", CRB0, sll0);

max_f = zeros(1, T);
sll = zeros(1, T);
mean_f = zeros(1, T);

for t = 1 : T
   num_children=1;
   offspring = zeros(N_Tx + N_Rx, 2, 7 * N);
   while num_children <= 7 * N
       pos = 1 + randi(N-1, 1, 2); % 1 * N
       % random choose two antenna posoiton as parents
       pa1 = X(:, :, pos(1));
       pa2 = X(:, :, pos(2));
       % generate child
       child = u * pa1 + (1-u) * pa2;
       % variance will be change with the increase of iteration
       sigma_new = sigma * exp(2 * (2 * (N_Tx + N_Rx))^(-1/2) * randn(N_Tx+N_Rx-1, 2));
       % children value changed by variance
       Y = child + sqrt([[0,0];sigma_new]) .* [[0,0];randn(N_Tx+N_Rx-1, 2)];
       % gaurentee the largest position of antannas are smaller than L
       if max(Y(:)) <= Lmax && min(Y(:)) >= 0 && ...
           min_distance_1D(Y(:,1)) >= min_interval/(radarParameter.wavelength/2) && ...
           min_distance_1D(Y(:,2)) >= min_interval/(radarParameter.wavelength/2)% 后面加天线距离的约束
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
       opm_P_unit = U(:,:,I(1));
       opm_P = to_virture_arrays(opm_P_unit(1:N_Tx, :), opm_P_unit(N_Tx+1:end, :), radarParameter);
   end
   
   max_f(t) = trace(CRB_func_2D(opm_P, radarParameter, objectParameter));
   sll(t) = get_SLL_2D_use_image(opm_P, radarParameter);
      fprintf("iteration: %d, CRB: %.5e, sll:%.2f \n", t, max_f(t), sll(t));
   mean_f(t) = mean(eva(I1)); % 计算每代平均适应度
%    if t >= 10 && mean(abs([max_f(t) - max_f(t-1), max_f(t-1) - max_f(t-2),...
%                     max_f(t-2) - max_f(t-3),  max_f(t-3) - max_f(t-4)])) <= 1e-6
%        break
%    end
end

% save("ES_results_20x4_SNR-5.mat")
%%
figure(1);
plot(1:T, max_f, 'b')

figure(2);
plot_ambi_func_2D(opm_P, radarParameter);