index = 0 : 0.001 : 10;
signal = sin(2*pi/index');
L = 64;
wvtool(rectwin(L), blackman(L), hanning(L), chebwin(L), gausswin(L));
wvtool(rectwin(L), blackman(L), hanning(L), chebwin(L));
wvtool(rectwin(L), blackman(L), hanning(L));
wvtool(rectwin(L), blackman(L));