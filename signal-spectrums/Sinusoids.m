% Signal definition:
Ts = 1/100000; %Sample period
t = 0:Ts:0.1;
f = [20, 100, 1000]';
phi = [0, pi/4, pi/2];
subplot(3, 1, 1)

for i=1:length(phi)
    signals = sin(2*pi*f*t + phi(i));
    subplot(3, 1, i)
    plot(t, signals)
    legend('f=20 Hz', 'f=100 Hz', 'f=1000 Hz')
    xlabel('t')
    title('phi='+string(phi(i)/pi)+'\pi')
end