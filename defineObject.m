function objectParameter = defineObject(range, speed, DOA, Amplitude, SNR)
    
%define the scenatio modeule parameters
    objectParameter.r0 = range;
    objectParameter.vr = speed;
    objectParameter.SNR = SNR;
    objectParameter.u = DOA;
    objectParameter.A = Amplitude; 
end