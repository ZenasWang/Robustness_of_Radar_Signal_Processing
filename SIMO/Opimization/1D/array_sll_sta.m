function [SLL, AFabs] = array_sll_sta ( A, n_points) % Compute the SLL and array factor ofl inear % arrays at the specified number of points.

% Compute the array factor magnitude.

AF _abs = abs (ifft(A , n_points)) ; % Normalise the array factor magnitude.

AF_abs = bsxfun (@rdivide, AF_abs, max (AF_abs)) ; % Allocate a variable for SLL results.

SLL = zeros (1, size (A, 2)) ; % The end of the unique half of the pattern.

half_end = ceil (n_points/2) + 2 ; % Estimate the extent of the main beam.

beam_end = n_points/size (A, 1) ; % Precompute the pattern differences.

AF_inc = diff (AF_abs (1: min (ceil (3*beam_end) , half_end), :)) > 0 ; for i_A = 1 : size (A, 2)

% Find first pattern magnitude increase.

SLL_ start = find (AF_inc (:, i_A), 1) ;

% If main beam is too broad.

if ( numel (SLL_start) == 0)

SLL_start = find (diff (AF_abs (1: half_end, i_A)) > 0, 1) ;

% If pattern has no nulls − unlikely.

if (numel (SLL_start) == 0)

SLL_start = 1 ;

end

end

% Compute the SLL.

SLL (i_A) = max (AF_abs (SLL_start : half_end, i_A)) ; end % for i_A = 1: size (A, 2)