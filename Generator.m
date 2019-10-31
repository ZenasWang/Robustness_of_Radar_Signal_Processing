
tpn = 0 : T_pn: T_full - T_full / N_pn;
k = 0 : N_chirp - 1; % in which chirp
ns = 0 : N_sample - 1;   % in which sample

fD = -2 * f0 * vr / c0;     % 1 x N_pn
fR = -2 * ramp * r0 / c0;   %scalar

for i = 1 : N_pn
    X(:, :, i) = A * exp(1j * 2 * pi * (-2 * f0(i) * r0 / c0))...
      * exp(1j * 2 * pi * (fD(i) * tpn(i)))...           % scalar
      * exp(1j * 2 * pi * fR * ns' * T_sample)...        % N_sample x 1
      * exp(1j * 2 * pi * fD(i) * k * T_chirp)...        % 1 x N_T_chirp
      * exp(1j * 2 * pi * f0(i) / c0 * (P_Tx(i) + P_Rx(i)) * u);
end

n = sigma * randn(N_sample, N_chirp, N_pn);
X = X + n;

subplot(2,1,1); stem(X(:, 1, 2));
fftx = fft(X(:, 1, 2));
subplot(2,1,2); stem(fftx);