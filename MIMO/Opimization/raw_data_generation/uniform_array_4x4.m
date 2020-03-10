function [Tx, Rx] = uniform_array_4x4()
% a function to generate uniform array 4x4
% return Tx and Rx array

Tx = zeros(4, 2);
Rx = zeros(4, 2);
Tx(1, :) = [0, 0];
Tx(2, :) = [0, 3];
Tx(3, :) = [3, 0];
Tx(4, :) = [3, 3];

Rx(1, :) = [1, 1];
Rx(2, :) = [1, 2];
Rx(3, :) = [2, 1];
Rx(4, :) = [2, 2];
end