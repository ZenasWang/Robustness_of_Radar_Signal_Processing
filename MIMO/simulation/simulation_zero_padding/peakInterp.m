function [ ind_hat ] = peakInterp( maxInd, data)
%PEAKINTERP Peak interpolation:
% 1. Zero padding with a factor of sizeNeighEvalInterv
% 2. Parabola interpolation around the maximum

% - maxInd   := Index of the Maximum bin
% - data     := The radarSignal for range, fft_range signal for velocity
% - ind_hat  := The interpolated index

%init
ind_hat = zeros(numel(maxInd),1);

%calc
N_p = numel(data);

for i = 1: numel(maxInd)
    if maxInd(i) == 1
        ind_hat(i) = 1;    
    elseif maxInd(i) == N_p
        ind_hat(i) = N_p; 
    else
        % DFT approx
        realMaxInd = maxInd(i);
        % Parab approx
        parabPar = [1 -1 1;1 0 0;1 1 1] \ (data([realMaxInd-1, realMaxInd, realMaxInd+1]));
        deltaPos = -parabPar(2) / (2*parabPar(3));

        realmaxpos = realMaxInd + deltaPos;
        ind_hat(i) = realmaxpos;
    end
end
end