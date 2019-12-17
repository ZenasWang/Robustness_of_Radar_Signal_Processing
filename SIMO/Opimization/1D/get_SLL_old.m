function [SLL] = get_SLL(P, radarParameter, objectParameter)

% get peak of the main lobe
% objectParameter = object_1;
main_lobe = ambiguity_func(0, 0, P, radarParameter, objectParameter);

% wave length
lamda = radarParameter.c0 / radarParameter.f0(1);
% max position of anttenas
L_max = max(P);
L_max = L_max(1);
% distance between each antenna for 均匀分布
d = L_max / (radarParameter.N_pn - 1);
% half width of the main lobe
u_3db = 0.891 * lamda/2/(radarParameter.N_pn)/d;
ambiguity_func(u_3db, 0, P, radarParameter, objectParameter);

% get peak value of the side lobe
ux_left = -1 : 0.01 : -u_3db;
ux_right = u_3db : 0.01 : 1;
uy = 0;
for x = 1 : length(ux_right)%(az)
  for y = 1 : length(uy)%(el = 0)
    Ambi(x,y) = ambiguity_func(ux_right(x), uy(y), P, radarParameter, objectParameter);
  end
end
% plot(ux_right, Ambi);

[SL_ux_ind, SL_uy_ind] = find(Ambi == max(Ambi(:)));

% SL_value = max(findpeaks(Ambi));
% SL_value = SL_value(1);
SL_value = Ambi(SL_ux_ind,SL_uy_ind);
SLL = SL_value / main_lobe;
end