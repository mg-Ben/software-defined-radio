% SNRcalculations.m: using linear filters to improve SNR

% Dominios:
T = 3; %[s]
fs = 48000; %[Hz]
Ts = 1/fs; %[s]
t = 0:Ts:T;

% (a) Model
% 1. Se define una señal x(t) que es aleatoria y su contenido frecuencial está entre 3KHz y 4KHz
fc1 = 3000; fc2 = 4000; %[Hz]
x = 2*randn(1,length(t));
fprintf('Potencia de x(t) antes del filtrado (equivalente a sigma^2):')
pow(x)
% Potencia de x ~= sigma^2 (ergodicidad) = 4
% Filtrado (normalizado a fs/2) - Definición del filtro:
transicion_Hz=100; %[Hz]
transicion=transicion_Hz/(fs/2);
freqs=[0 fc1/(fs/2)-transicion fc1/(fs/2) fc2/(fs/2) fc2/(fs/2)+transicion 1];
amps=[0 0 1 1 0 0];
b=firpm(1440,freqs,amps);
% Respuesta en frecuencia del filtro:
[h,w] = freqz(b,1,512);
figure;
plot((w/pi)*(fs/2),abs(h))
hold on
for i = 1:2:length(freqs)
    plot([freqs(i)*fs/2 freqs(i+1)*fs/2],[amps(i) amps(i+1)],"r--")
end
hold off
% Filtrado - Filtrado de la señal:
x=filter(b,1,x);

fprintf('Potencia de x(t) tras el filtrado (equivalente al ancho de banda (B=2*1000Hz) entre fs (banda total, 48000Hz) multiplicado por la potencia inicial (4). Debería resultar en ~0.1667 [W]:')
pow(x)
% Comprobación de señal filtrada:
figure;
plotspec(x,Ts, 'x(t)', '|X(j\omega)|', t)

% 2. Se añade ruido n(t)
n=0.25*randn(1,length(t));
% Se obtiene una aproximación discreta a la PSD del ruido a partir de su DFT
% junto con la potencia / varianza (proceso ergódico)
N=length(n);
f=(ceil(-N/2):ceil(N/2)-1)/(Ts*N);       % frequency vector
fn=fft(n);                            % do DFT/FFT
fns=fftshift(fn);
psd_n = (Ts/N)*(abs(fns).^2);
figure;
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
fprintf('Varianza de n(t):')
var(n)
% Potencia del proceso, obtenida como una aproximación a la integral de la
% PSD:
fprintf('Potencia de n(t), obtenida como una aproximación a la integral de la PSD:')
sum(psd_n)*1/(Ts*N)

% Se obtiene lo mismo que con pow(n)

% 3. Se obtiene la señal de salida como el filtrado Paso Banda de x+n:
r = filter(b,1,x+n);
figure;
plotspec(r,Ts, 'r(t)', '|R(j\omega)|', t)

% 4. Se obtiene la SNR a la entrada:
snrinp=pow(x)/pow(n)

% -------------------------------------------------------------------------

% (b) Model
% 1. Se filtra x(t) por un lado y n(t) por el otro y se suman:
yx=filter(b,1,x);
yn=filter(b,1,n);
y = yx+yn;
% 2. Se puede verificar que es ~= x(t) + n(t) filtrada del caso (a)
diffzy=max(abs(r-y))

% 3. Se obtiene la SNR a la salida:
snrout=pow(yx)/pow(yn)
