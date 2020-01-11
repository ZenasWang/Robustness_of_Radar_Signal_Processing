function [min_dis] = min_distance_1D(array)

sorted_arr = sort(array);
min_distance = Inf;
for i = 1 : length(sorted_arr)-1
    if abs(sorted_arr(i) - sorted_arr(i+1)) < min_distance
        min_distance = abs(sorted_arr(i) - sorted_arr(i+1));
    end
end
min_dis = min_distance;
end