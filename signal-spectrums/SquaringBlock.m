% Signal definition:
Ts = 1/1000; %Sample period
t = 0:Ts:0.1;
f = 100; %Cosine frequency [Hz]
s = cos(2*pi*f*t);
s = s.^2;

title1='s(t)';
title2='S(f)';
figure;
plotspec(s, Ts, title1, title2, t)


% Two cosine waves:
t = 0:Ts:0.1;
f1 = 100; %Cosine 1 frequency [Hz]
f2 = 150; %Cosine 2 frequency [Hz]
s = cos(2*pi*f1*t) + cos(2*pi*f2*t);
s = s.^2;

title1='s(t)';
title2='S(f)';
figure;
plotspec(s, Ts, title1, title2, t)


% Filtered noise between 100 Hz and 300 Hz:
t = 0:Ts:10;
s=randn(1, length(t));
amps=[0 0 1 1 0 0];
freqs=[0 100/(1/(2*Ts))-0.1 100/(1/(2*Ts)) 300/(1/(2*Ts)) 300/(1/(2*Ts))+0.1 1];
% Normalized frequencies would be: 100/(fs/2) and 300/(fs/2), where fs is
% 1/Ts (fs/2 represents the limits of spectrum when sampling a signal)

b=firpm(100, freqs, amps);
filtered_s=filter(b, 1, s);
s = filtered_s.^2;
title1='s(t)';
title2='S(f)';
figure;
plotspec(filtered_s, Ts, title1, title2, t)