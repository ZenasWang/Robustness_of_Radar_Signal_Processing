X = sqrt(2)*sin(0:pi/1000000:6*pi);               %产生正弦信号

Y = awgn(X,10,'measured');                          %加入信噪比为10db的噪声，加入前预估信号的功率（强度）

sigPower = bandpower(X)
%= sum(abs(X).^2)/length(X)           %求出信号功率

noisePower=sum(abs(Y-X).^2)/length(Y-X)  %求出噪声功率

SNR=10*log10(sigPower/noisePower)          %由信噪比定义求出信噪比，单位为db