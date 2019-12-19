function signal = signalGenerator_SO( radarParameter, objectParameter ) % input 
% a function to generate radar signal use our signal model

% from which Tx
t_pn = [-radarParameter.N_Tx/2 : -1, 1 : radarParameter.N_Tx/2] * radarParameter.T_pn;
% in which chirp
t_slow = (0 : radarParameter.N_chirp - 1) * radarParameter.T_chirp; 
 % in which sample
t_fast = (0 : radarParameter.N_sample - 1) * radarParameter.T_sample;  
% phaseshift because of vr
fD = -2 * radarParameter.f0 * objectParameter.vr / radarParameter.c0;
% phaseshift because of r0
fR = -2 * radarParameter.ramp * objectParameter.r0 / radarParameter.c0;   %scalar

% build TDM radar signal

% loop version
% tic
% X = zeros(radarParameter.N_sample, radarParameter.N_chirp, radarParameter.N_pn);
% 
% for i = 1 : radarParameter.N_pn
%     X(:, :, i) = objectParameter.A ...
%       * exp(1j * 2 * pi * (-2 * radarParameter.f0 * objectParameter.r0 / radarParameter.c0))...
%       * exp(1j * 2 * pi * (fD * t_pn(ceil(i/radarParameter.N_Rx))))... % scalar
%       * exp(1j * 2 * pi * fR * t_fast')... % N_sample x 1
%       * exp(1j * 2 * pi * fD * t_slow)... % 1 x N_T_chirp
%       * exp(-1j * 2 * pi / radarParameter.wavelength... 
%                        * radarParameter.P(i, :) * objectParameter.u');
% 
%         X_n(:, :, i) = awgn(X(:, :, i), objectParameter.SNR, 'measured');
% end   
% toc

% fast version, just a half time
X = objectParameter.A... 
      * repmat(exp(1j * 2 * pi * fR * t_fast')...
      * exp(1j * 2 * pi * fD * t_slow), 1, 1, radarParameter.N_pn)... 
      .* reshape(exp(1j * 2 * pi * (-2 * radarParameter.f0 * objectParameter.r0 / radarParameter.c0))...
      .* exp(1j * 2 * pi * (fD * kron(t_pn', ones([radarParameter.N_Rx,1]))))...   
      .* exp(-1j * 2 * pi / radarParameter.wavelength... 
      * radarParameter.P * objectParameter.u'), 1, 1, radarParameter.N_pn);
% add white gaussian noise
signal = awgn(X, objectParameter.SNR, 'measured');   
end