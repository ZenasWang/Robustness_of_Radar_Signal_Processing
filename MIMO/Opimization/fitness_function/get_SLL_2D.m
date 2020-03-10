function [SLL] = get_SLL_2D(P, radarParameter, objectParameter)

% clc
% clear
% radarParameter = defineRadar(94e9 , 3e9, 10e6,...
%                            160, 1000, [0,0,0], [0,0,0;1,0,0;0,1,0;1,1,0;0,2,0;2,0,0;2,1,0;1,2,0;2,2,0]);
% objectParameter = defineObject(15, 2, [0,0,0], 1, -5);
% P = radarParameter.P;

% wave length
lamda = radarParameter.c0 / radarParameter.f0(1);
% max position of anttenas
L_max = max(P);
L_max = L_max(1);
% distance between each antenna for 均匀分布
d = L_max / (radarParameter.N_pn - 1);
% half width of the main lobe
u_3db = 0.891 * lamda/2/(radarParameter.N_pn)/d;
ux = -1 : 0.01 : 1;
uy = 0 : 0.01 : 1;

% [UY, UX] = meshgrid(ux, uy);
% tic
% ambi_fun_temp = @(x,y)ambiguity_func(x,y,P, radarParameter, objectParameter);
% Ambi0 = arrayfun(ambi_fun_temp, UX, UY);
% toc
% Ambi0(100,200)

Ambi = zeros(length(ux), length(uy));
for x = 1 : length(ux)%(az)
  for y = 1 : length(uy)%(el = 0)
    Ambi(x,y) = ambiguity_func(ux(x), uy(y), P, radarParameter, objectParameter);
  end
end

% surf(ux, uy, Ambi)

norm_Ambi = Ambi / max(Ambi(:));
main_lobe =  max(Ambi(:));
[under_half_x_ind, under_half_y_ind] = find(norm_Ambi <= 0.5);
under_half_mat_ind = [under_half_x_ind, under_half_y_ind];
under_half_mat = [ux(under_half_x_ind)', uy(under_half_y_ind)'];

dist_to_mainlobe = sqrt(sum(under_half_mat .^2, 2));
min_dist_to_mainlobe = find(dist_to_mainlobe == min(dist_to_mainlobe(:)));
u_3db = under_half_mat(min_dist_to_mainlobe, :);
beta = 1.3;
u_3db_x = beta * abs(u_3db(1,1));
u_3db_y = beta * abs(u_3db(1,2));

ux_for_sll = [-1:0.01:-u_3db_x, u_3db_x:0.01:1];
uy_for_sll = [-1:0.01:-u_3db_y, u_3db_y:0.01:1];
Ambi_out_3db = zeros(length(ux_for_sll), length(uy_for_sll));
for x = 1 : length(ux_for_sll)  %(az)
  for y = 1 : length(uy_for_sll)    %(el)
    Ambi_out_3db(x,y) = ambiguity_func(ux_for_sll(x), uy_for_sll(y), P, radarParameter, objectParameter);
  end
end
% [SL_ux_ind, SL_uy_ind] = find(Ambi_out_3db == max(Ambi_out_3db(:)));
SLL = max(Ambi_out_3db(:)) / main_lobe;
end