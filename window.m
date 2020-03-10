t = 0 : 0.0001 : 2;
s = sin(2 * pi / 0.3 * t);
subplot(1,2,1);
plot(t, s);
xlabel('t');
ylabel('Amplitude')
win = chebwin(numel(s));
s1 = s .* win';
subplot(1,2,2)
plot(t, win, 'g');
xlabel('t');
ylabel('Amplitude')
hold on;
plot(t, s1, 'r');
plot(t, -win, 'g');

legend('window', 'signal after adding window')


