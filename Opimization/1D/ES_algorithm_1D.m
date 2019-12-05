clear
clc
radarParameter = defineRadar(94e9 , 3e9, 10e6,...
                           160, 1000, [0,0,0], [0,0,0;1,0,0;2,0,0;3,0,0;4,0,0;5,0,0;6,0,0;7,0,0]);
objectParameter = defineObject(15, 2, [0,0,0], 1, -5);
%波长
lamda = radarParameter.c0 / radarParameter.f0(1);
N_pn = radarParameter.N_pn;   % 天线个数
N = 20; % 初始种群规模
% 初始化天线位置
L = lamda * 20;
% X 为 N_pn x 3 x N

% if initialized by random choise in 0-L
% X = zeros(N_pn, 3, N);
% 生成初始种群矩阵，一层表示一个可行解，一行表示一个天线
% P_x = L * rand(N_pn - 1, N);    %所有天线范围在[0, L] 之间
% X(2:N_pn, 1, :) = P_x;

% if initialized by uniform distribution
X = repmat([0,0,0;1,0,0;2,0,0;3,0,0;4,0,0;5,0,0;6,0,0;7,0,0]*lamda/2, 1,1,N);
% % 初始化方差
sigma = L^2 / N_pn^2;
u = 0.5; % 交叉比率
T = 50; % 迭代次数
maxf = Inf; % 记录最大适应度
CRB0 = CRB_func_1D(radarParameter.P, radarParameter, objectParameter);
sll0 = get_SLL_1D(radarParameter.P, radarParameter, objectParameter);
fprintf("iteration: 0, CRB: %.5e, sll:%.2f \n", CRB0, sll0);
for t = 1:T
   num_children=1;
   while num_children <= 7 * N
       pos = 1 + randi(N-1, 1, 2); % [1,N]范围的二元行向量
    % pa1、pa2分别是X中的一个随机解，可能相同
       pa1 = X(:, :, pos(1));
       pa2 = X(:, :, pos(2));
       % 构造子代
       child = u * pa1 + (1-u) * pa2;
       % 变异强度随进化而改变
       sigma_new = sigma * exp(2 * (2 * N_pn)^(-1/2) * randn(N_pn-1,1));
       % 子代产生变异
       Y = child + sqrt([[0,0,0];[sigma_new,zeros(N_pn - 1, 1), zeros(N_pn - 1, 1)]]) ...
           .* [[0,0,0];[randn(N_pn -1, 1), zeros(N_pn - 1, 1), zeros(N_pn - 1, 1)]];
       % Y这个解可能会超出范围 x1,x2
       if max(Y(:)) <= L && min(Y(:)) >= 0% && min_distance_1D(Y) >= 1.5* lamda% 后面加天线距离的约束
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 保存选择出来的个体，个体数目lamda+1
           offspring(:,:,num_children) = Y; % 保存选择出来的子代
           num_children = num_children+1; 
       end
   end
   U = offspring; %个解组成的矩阵 这里是(µ,λ)策略, 2 x 70
   % u,λ选择策略: 从新生成的λ个体中选择 ,建议λ/μ = 7
   % μ/λ是压力比，其越大选择压力越大。
   % u + λ策略改为U=[offspring, X]
   % size(U, 2) 为U向量的列数，也就是子代数目, 7*N = 70
   for i = 1: size(U,3)
       temp = U(:, :, i);   % N_pn x 3
       eva(i) = fitness_func_1D(temp, radarParameter, objectParameter);   %把子代的70个个体适应度方程写出来
   end
   % m_eval是排序的适应度值，从小到大，I是对应的适应值原来的下标
   [m_eval,I] = sort(eva);
   I1 = I(1: N); % 从7*N子代中选出最小的N个的适应度下标行向量
   X = U(:,:,I1); % 把取出来的最小的下标代入，得到7*N中最好的N个个体
   % 比较最大适应度与maxf记录值，更新maxf,同时记录x1,x2值
   if m_eval(1) < maxf
       maxf = m_eval(1);
       opm_P = U(:,:,I(1));
   end
   max_f(t) = CRB_func_1D(opm_P, radarParameter, objectParameter);
   sll(t) = get_SLL_1D(opm_P, radarParameter, objectParameter);
      fprintf("iteration: %d, CRB: %.5e, sll:%.2f \n", t, max_f(t), sll(t));
   mean_f(t) = mean(eva(I1)); % 计算每代平均适应度
end
figure;
subplot(2,1,1)
plot(1:T,max_f,'b',1:T,mean_f,'g')
ux = -2 : 0.01 : 2;
for i = 1: size(ux,2)
    Ambi(i) = ambiguity_func_1D(ux(i), 0, opm_P, radarParameter, objectParameter);
end
Ambi = Ambi/ max(Ambi(:));
subplot(2,1,2)
plot(ux, Ambi)
opm_P
maxf

function [value] = fitness_func_1D(P, radarParameter, objectParameter)
CRB = CRB_func_1D(P, radarParameter, objectParameter);
SLL = get_SLL_1D(P, radarParameter, objectParameter);
if SLL <= 0.5
    beta = 0;
else
    beta = 1;
end
value = (1-beta) * CRB + beta * SLL;
end












