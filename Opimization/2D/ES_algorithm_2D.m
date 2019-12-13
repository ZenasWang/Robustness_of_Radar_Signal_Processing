clear
clc
radarParameter = defineRadar(94e9 , 3e9, 10e6,...
                           160, 1000, [0,0,0], [0,0,0;1,0,0;0,1,0;1,1,0;0,2,0;2,0,0;2,1,0;1,2,0;2,2,0]);
objectParameter = defineObject(15, 2, [0,0,0], 1, 8);

lambda = radarParameter.c0 / radarParameter.f0(1);  % wave length
N_pn = radarParameter.N_pn;   % number of all virtual antenna
N = 30;  % first population number
% lagest distance between antennas
L = lambda * 10;

% % X 为 N_pn x 3 x N
% % if initialized by random choise in 0-L
% X = zeros(N_pn, 3, N);
% % generate N initialized antenna
% P_x = L * rand(N_pn - 1, N);    % the range of antenna is between [0, L]
% P_y = L * rand(N_pn - 1, N);
% X(2:N_pn, 1, :) = P_x;
% X(2:N_pn, 2, :) = P_y; 

% if initialized by uniform distribution
X = repmat([0,0,0;1,0,0;0,1,0;1,1,0;0,2,0;2,0,0;2,1,0;1,2,0;2,2,0]*lambda/2, 1,1,N);

% initialize variance strength
sigma = L^2 / sqrt(N_pn)^2;
% sigma = L^2 / N_pn^2;

% cross ratio
u = 0.5;
% iteration bumbers
T = 50;
% track maximum fitness for every iteration
maxf = Inf;
CRB0 = trace(CRB_func_2D(radarParameter.P, radarParameter, objectParameter));
sll0 = get_SLL_2D_use_image(radarParameter.P, radarParameter, objectParameter);
fprintf("iteration: 0, CRB: %.5e, sll:%.2f \n", CRB0, sll0);

for t = 1 : T
   num_children=1;
   offspring = zeros(N_pn, 3, 7 * N);
   while num_children <= 7 * N
       pos = 1 + randi(N-1, 1, 2); % 1 * N
       % random choose two antenna posoiton as parents
       pa1 = X(:, :, pos(1));
       pa2 = X(:, :, pos(2));
       % generate child
       child = u * pa1 + (1-u) * pa2;
       % variance will be change with the increase of iteration
       sigma_new = sigma * exp(2 * (2 * sqrt(N_pn))^(-1/2) * randn(N_pn-1,2));
%        sigma_new = sigma * exp(2 * (2 * N_pn)^(-1/2) * randn(N_pn-1,2));
       % children value changed by variance
       Y = child + sqrt([[0,0,0];[sigma_new, zeros(N_pn - 1, 1)]]) ...
           .* [[0,0,0];[randn(N_pn -1, 2), zeros(N_pn - 1, 1)]];
       % gaurentee the largest position of antannas are smaller than L
       LD = sqrt(sum(Y.^2, 2));
       if max(LD(:)) <= L && min(Y(:)) >= 0 % && min_distance_1D(Y) >= 1.5* lamda% 后面加天线距离的约束
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
   % u + λ策略改为U=[offspring, X]
   parfor i = 1: size(U,3)
       temp = U(:, :, i);   % N_pn x 3
       eva(i) = fitness_func_2D(temp, radarParameter, objectParameter);   %把子代的70个个体适应度方程写出来
   end
%    fprintf("successfully evoluted\n")
   % m_eval是排序的适应度值，从小到大，I是对应的适应值原来的下标
   [m_eval,I] = sort(eva);
   I1 = I(1: N); % 从7*N子代中选出最小的N个的适应度下标行向量
   X = U(:,:,I1); % 把取出来的最小的下标代入，得到7*N中最好的N个个体
   % 比较最大适应度与maxf记录值，更新maxf,同时记录x1,x2值
   if m_eval(1) < maxf
       maxf = m_eval(1);
       opm_P = U(:,:,I(1));
   end
   max_f(t) = trace(CRB_func_2D(opm_P, radarParameter, objectParameter));
   sll(t) = get_SLL_2D_use_image(opm_P, radarParameter, objectParameter);
      fprintf("iteration: %d, CRB: %.5e, sll:%.2f \n", t, max_f(t), sll(t));
   mean_f(t) = mean(eva(I1)); % 计算每代平均适应度
%    if t >= 10 && mean(abs([max_f(t) - max_f(t-1), max_f(t-1) - max_f(t-2),...
%                     max_f(t-2) - max_f(t-3),  max_f(t-3) - max_f(t-4)])) <= 1e-6
%        break
%    end
end
%%
figure;
subplot(4,1,1)
plot(1:t, max_f, 'b')

ux = -1 : 0.01 : 1;
uy = -1 : 0.01 : 1;
for x = 1 : length(ux)%(az)
  for y = 1 : length(uy)%(el = 0)
    Ambi_mat(x,y) = ambiguity_func(ux(x), uy(y), opm_P, radarParameter, objectParameter);
  end
end
Ambi_mat = Ambi_mat / max(Ambi_mat(:));
subplot(4,1,[2:4]);
surf(ux,uy, Ambi_mat);
axis('equal');

function [value] = fitness_func_2D(P, radarParameter, objectParameter)
CRB_2D = CRB_func_2D(P, radarParameter, objectParameter);
CRB = trace(CRB_2D);
SLL = get_SLL_2D_use_image(P, radarParameter, objectParameter);
if SLL <= 0.5
    beta = 0;
else
    beta = 1;
end
value = (1-beta) * CRB + beta * SLL;
end


function [value] = fitness_func_2D_2(P, radarParameter, objectParameter)
CRB_2D = CRB_func_2D(P, radarParameter, objectParameter);
CRB = trace(CRB_2D);
SLL = get_SLL_2D_use_image(P, radarParameter, objectParameter);
if SLL <= 0.5
    beta = 0;
else
    beta = 0.5;
end
value = CRB + beta * SLL;
end