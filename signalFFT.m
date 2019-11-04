function fftSignal = signalFFT(radarSignal,  N_sample, N_chirp)
fftSignal = abs(fftshift(fft2(radarSignal, 3 * N_sample, 3 * N_chirp))) .^ 2;
end