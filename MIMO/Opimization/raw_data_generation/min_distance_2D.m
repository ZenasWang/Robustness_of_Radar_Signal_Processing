function [min_dis] = min_distance_2D(array)
% a function to get minimul distance between arrays
% 之后用分治算法写
sorted_arr = sort(array, 1);
min_dis = Inf;
for i = 1 : size(sorted_arr, 1) - 1
    for j = i+1 : size(sorted_arr, 1)
        if sqrt(sum((sorted_arr(i, :) - sorted_arr(j,:)).^2)) < min_dis
            min_dis = sqrt(sum((sorted_arr(i, :) - sorted_arr(j,:)).^2));
        end
    end
end
end