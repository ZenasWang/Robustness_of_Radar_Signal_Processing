function objectParameter = defineObject(range, speed, DOA, sigma)
    %define the scenatio modeule parameters
    objectParameter.r0 = range;
    objectParameter.vr = speed;
    objectParameter.sigma = sigma;
    objectParameter.u = DOA;
end