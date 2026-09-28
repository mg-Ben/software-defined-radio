% SNRcalculations.m: using linear filters to improve SNR

time=3;                   % time
Ts=1/48000;               % sampling interval: WRONG
t = 0:Ts:time;
%----------------------------------
freqs=[0 0.1 0.125 0.1667 0.19167 1];    % filter design, bandlimited
amps=[0 0 1 1 0 0];
%----------------------------------
b=firpm(100,freqs,amps);          % BP filter
n=0.25*randn(1,length(t));          % generate white noise signal
%**********************************


% Calculate the PSD of n. Insert code.
N=length(n);
f=(ceil(-N/2):ceil(N/2)-1)/(Ts*N);       % frequency vector
fn=fft(n);                            % do DFT/FFT
fns=fftshift(fn);
psd_n = (Ts/N)*(abs(fns).^2);

% Plot it and check with the noise variance
plot(f, psd_n)
xlabel('f')
ylabel('S_x_x(f)')
% Dado que el ruido (n) es un proceso estacionario, se puede estudiar su
% ergodicidad. En este caso,
% coincide el promedio
% temporal de la señal ^2 (o, equivalentemente, potencia) con la Esperanza
% de la Variable aleatoria ^2 (como el promedio es 0, coincide por
% definición con la varianza)
% Varianza del proceso:
var(n)
% Potencia del proceso, obtenida como una aproximación a la integral de la
% PSD:
sum(psd_n)*1/(Ts*N)

% As a starting point use the code for plotting
% spectra you'll find belowcd Des   cd

%**********************************
x=filter(b,1,2*randn(1,time/Ts)); % do the filtering
y=filter(b,1,x+n);                % (a) filter the signal+noise
yx=filter(b,1,x);                 % or (b) filter signal 
yn=filter(b,1,n);                 % ...and noise separately
z=yx+yn;                          % add them
diffzy=max(abs(z-y))              % and make sure y = z
%**********************************


% Obtain the theoretical values of SNR
% and check them with the estimates provided
% by the two following lines of code
 
%**********************************
snrinp=pow(x)/pow(n)              % SNR at input
snrout=pow(yx)/pow(yn)            % SNR at output

%**********************************

% Repeat for a 2 kHz sinusoid with the same power than the noise

%**********************************


% How to plot spectra
%N=length(x);                         % length of the signal x
%t=Ts*(1:N);                          % define time vector
%ssf=(-N/2:N/2-1)/(Ts*N);             % frequency vector

% fx=fftshift(fft(x(1:N)+n(1:N)));
% figure(5), subplot(2,1,1), plot(ssf,abs(fx))
% xlabel('magnitude spectrum of signal + noise')
% 
% fy=fftshift(fft(y(1:N)));
% subplot(2,1,2), plot(ssf,abs(fy))
% xlabel('magnitude spectrum after filtering')