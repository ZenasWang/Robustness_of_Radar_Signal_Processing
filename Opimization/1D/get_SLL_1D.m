function [SLL] = get_SLL_1D(P, radarParameter, objectParameter)
% get peak of the main lobe
% objectParameter = object_1;
main_lobe = ambiguity_func(0, 0, P, radarParameter, objectParameter);
ux = 0 : 0.001 : 2;
uy = 0;
y = 1;
for x = 1 : length(ux)
    Ambi_full(x,y) = ambiguity_func(ux(x), uy, P, radarParameter, objectParameter);
end
norm_Ambi_full = Ambi_full/max(Ambi_full(:));
[Ambi_half_x, Ambi_half_y] = find(norm_Ambi_full <= 0.5);
% u_3db = ux(Ambi_half_x(1));
% norm_Ambi_full(Ambi_half_x(2),1);
u_3db = Ambi_half_x(1);
% half width of the main lobe
ambiguity_func(u_3db, 0, P, radarParameter, objectParameter);
% get peak value of the side lobe
ux_right = u_3db : length(ux);
norm_Ambi_main_out = norm_Ambi_full(ux_right, 1);
[SL_ux_ind, SL_uy_ind] = find(norm_Ambi_main_out == max(norm_Ambi_main_out(:)));
% uy = 0;
% for x = 1 : length(ux_right)%(az)
%   for y = 1 : length(uy)%(el = 0)
%     Ambi(x,y) = ambiguity_func(ux_right(x), uy(y), P, radarParameter, objectParameter);
%   end
% end
% plot(ux_right, Ambi);

% [SL_ux_ind, SL_uy_ind] = find(Ambi == max(Ambi(:)));

% SL_value = max(findpeaks(Ambi));
% SL_value = SL_value(1);
% SL_value = Ambi(SL_ux_ind,SL_uy_ind);
SLL = norm_Ambi_main_out(SL_ux_ind, SL_uy_ind);
end