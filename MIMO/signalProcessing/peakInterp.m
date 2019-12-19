function [ ind_hat ] = peakInterp( maxInd, data, isVel )
%PEAKINTERP Peak interpolation:
% 1. Zero padding with a factor of sizeNeighEvalInterv
% 2. Parabola interpolation around the maximum
% - maxInd   := Index of the Maximum bin
% - data     := The radarSignal for range, fft_range signal for velocity
% - ind_hat  := The interpolated index

%def
sizeNeighEvalInterv = 3;  %eval 4 points (>3), enough for parable fit (requires 3 points)

%init
ind_hat = zeros(numel(maxInd),1);

%calc
if isVel
    N_p = size(data, 2);
    spec_zp = fftshift(sum(abs(fft((data), 3*N_p, 2)), 3)); % conj or not, why?

else
    N_p = size(data, 1);
    spec_zp = sum(sum(abs(fft(data, 3*N_p, 1)), 2), 3)';
end

for i = 1: numel(maxInd)
    if maxInd(i) == 1
        ind_hat(i) = 1;    
    elseif maxInd(i) == N_p
        ind_hat(i) = N_p; 
    else
        % DFT approx
        realMaxInd = maxInd(i);
        fineSpace = (realMaxInd-2) * sizeNeighEvalInterv + 1 : realMaxInd*sizeNeighEvalInterv+1;
        fineSpec = spec_zp(fineSpace);
        [~,fineMaxInd] = max(fineSpec);
        maxIndFine = fineSpace(fineMaxInd);
        
        if maxIndFine > 1 && maxIndFine < N_p * sizeNeighEvalInterv - 1 ...
            &&fineMaxInd > 1 && fineMaxInd < numel(fineSpace) - 1
            % Parab approx
            parabPar = [1 -1 1;1 0 0;1 1 1] \ (spec_zp([maxIndFine-1,maxIndFine,maxIndFine+1])');
            deltaFinePos = -parabPar(2) / (2*parabPar(3));
        else
            deltaFinePos=0;
        end

        realmaxpos = (maxIndFine -1 + deltaFinePos) / (sizeNeighEvalInterv) + 1; % +1 or not
        ind_hat(i) = realmaxpos;
    end
end
end