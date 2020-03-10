function signal = array_response( radarParameter, objectParameter, SNR) % input 

E = -2*pi / radarParameter.c0 * radarParameter.f0 * radarParameter.P;
X = exp(1j*(E * objectParameter.u'));

% add white gaussian noise
signal = awgn(X, SNR);
end