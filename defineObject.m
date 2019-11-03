function objectParameter = defineObject(range, speed, DOA, Amplitude, sigma)
    %define the scenatio modeule parameters
    objectParameter.r0 = range;
    objectParameter.vr = speed;
    objectParameter.sigma = sigma;
    objectParameter.u = DOA;
    objectParameter.A = Amplitude; 
end