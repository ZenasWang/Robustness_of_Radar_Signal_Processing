function objectParameter = defineObject( range, speed, DOA, Amplitude, SNR )
% define the scenatio modeule parameters for one target
% range, speed, doa are relative
% doa is a array with 2 element(like [ux, uy]) 
% the metrics of SNR is db

objectParameter.r0 = range;
objectParameter.vr = speed;
objectParameter.SNR = SNR;
objectParameter.u = DOA;
objectParameter.A = Amplitude; 

end