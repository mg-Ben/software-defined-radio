% plotspec(x,Ts) plots the spectrum of the signal x
% Ts = time (in seconds) between adjacent samples in x
function plotspec(x,Ts, title1, title2, t)
N=length(x);                               % length of the signal x
ssf=(ceil(-N/2):ceil(N/2)-1)/(Ts*N);       % frequency vector
fx=fft(x(1:N));                            % do DFT/FFT
fxs=fftshift(fx);                          % shift it for plotting
subplot(2,1,1);
plot(t,x)                  % plot the waveform
xlabel('t'); ylabel(title1)     % label the axes
title(title1)
subplot(2,1,2);
plot(ssf,abs(fxs))         % plot magnitude spectrum
xlabel('f'); ylabel(title2)   % label the axes
title(title2)
