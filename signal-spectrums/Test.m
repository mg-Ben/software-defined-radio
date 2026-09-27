time = 3; % Length of time
Ts = 1/10000; % Time interval between samples
t = 0:Ts:time;
x = randn(1, length(t)); % Generate noise signal

title1='s(t)';
title2='S(f)';

% Low-Pass (LP) Filter
figure;
plotspec(x, Ts, title1, title2, t) % Draw spectrum of input
freqs = [0 0.2 0.3 1]; % Note: Fixed frequency vector to match amps length (4 elements)
amps = [1 1 0 0];
b = firpm(100, freqs, amps); % Specify the LP filter
ylp = filter(b, 1, x); % Do the filtering
figure;
plotspec(ylp, Ts, title1, title2, t) % Plot the output spectrum

% Band-Pass (BP) Filter
freqs = [0 0.24 0.26 0.5 0.6 1]; % Note: Fixed frequency vector to match amps length (6 elements)
amps = [0 0 1 1 0 0];
b = firpm(100, freqs, amps); % BP filter
ybp = filter(b, 1, x); % Do the filtering
figure;
plotspec(ybp, Ts, title1, title2, t) % Plot the output spectrum

% High-Pass (HP) Filter
freqs = [0 0.74 0.76 1]; 
amps = [0 0 1 1];
b = firpm(100, freqs, amps); % Specify the HP filter
yhp = filter(b, 1, x); % Do the filtering
figure;
plotspec(yhp, Ts, title1, title2, t) % Plot the output spectrum
