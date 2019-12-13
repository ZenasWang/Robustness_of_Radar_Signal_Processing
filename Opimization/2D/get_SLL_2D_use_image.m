function [SLL] = get_SLL_2D_use_image(P, radarParameter, objectParameter)

% clc
% clear
% radarParameter = defineRadar(94e9 , 3e9, 10e6,...
%                            160, 1000, [0,0,0], [0,0,0;1,0,0;0,1,0;1,1,0;0,2,0;2,0,0;2,1,0;1,10,0;2,2,0]);
% objectParameter = defineObject(15, 2, [0,0,0], 1, -5);
% P = radarParameter.P;

ux = -1 : 0.01 : 1;
uy = -1 : 0.01 : 1;

Ambi = zeros(length(ux), length(uy));
for x = 1 : length(ux)%(az)
  for y = 1 : length(uy)%(el)
    Ambi(x,y) = ambiguity_func(ux(x), uy(y), P, radarParameter, objectParameter);
  end
end
% surf(ux, uy, Ambi)

% get local max of ambiguity function
peaks = imregionalmax(Ambi);
peaksIdx_struct = regionprops(peaks,'PixelIdxList');
% figure
% imagesc(peaks); % view max. peaks
peaksIdx = cell2mat(struct2cell(peaksIdx_struct));
Ambi_peaks = Ambi(peaksIdx);
sorted_Ambi_peak = sort(Ambi_peaks);
SLL = sorted_Ambi_peak(end-1)./sorted_Ambi_peak(end);
end