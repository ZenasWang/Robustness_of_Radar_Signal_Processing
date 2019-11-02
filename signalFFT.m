function s = signalFFT(radarParameters)
fft_range = sqrt(size(radarData,1)) * fft(radarData,[],1);
rangeSpec = sum(abs(fft_range),2);

% sum of all range spectra of the antennas
rangeSpec_sum = sum(rangeSpec,3);
end