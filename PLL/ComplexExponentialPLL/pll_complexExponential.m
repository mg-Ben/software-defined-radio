%PLL Example 1
%complex exponential PLL
clear; clf; clc

%% PLL Input signal
% Received continuous-time signal model: 
%      r(t) = exp(j*2*pi*(f0+deltaf0)*t + theta) + noise
%
% Received signal. Parameters and perturbations 
fs = 500; Ts=1/fs;  %sampling frequency
f0       = 50;      %exponential signal frequency (Hz):
deltaf0  = 3;       %frequency offset (Hz)
% A partir de 84Hz no converge (no se adapta a la velocidad de cambio de la
% señal de entrada)
% Cuando k2 = 0, el sistema converge, pero no a 0, con deltaf0 > 0. Esto se debe a
% que la función de error crecería linealmente según k en régimen estacionario cuando existe un deltaf0.
% Para que converja el error a 0, theta[k] debería compensar linealmente ese crecimiento, ya que:
% e[k] = 2*pi*deltaf0*kTs - theta[k]
% Por tanto, para que en régimen estacionario e[k] = 0,
% theta[k] = 2*pi*deltaf0*kTs (en régimen estacionario)
% Sin embargo, cuando se tiene k2 = 0, el e[k] no tiende nunca a 0, sino a
% 2*pi*deltaf0*Ts/k1 (se puede demostrar sustituyendo en e[k] theta[k] =
% theta[k-1] + k1e[k-1] y buscando
% dejar la expresión solo en función de e[k-1] para después tener e[k] en
% función de e[k-1] (ecuación fundamental del error. Para ver lo que sucede en régimen estacionario, se cogería esa relación y se igualaría a una constante. Esa constante finalmente dependerá de deltaf0 y k1).

phi      = pi/4;    %phase offset (radians)
Pn       = 0;        %Noise power
% La potencia máxima para que funcione son 8w.

%Sampling the signal. r[n]=r(nTs), t=nTs
N  = 1000; %samples
n  = 0:N-1;
w0 = 2*pi*f0*Ts;
exp_in = exp(1j*(2*pi*(f0+deltaf0)*n*Ts + phi)); % exponetial input
noise  = (1/2)*sqrt(Pn)*(randn(1,N) + 1j*randn(1,N));  % noise
r = exp_in + noise;                                    % PLL input


%% PLL parameters
Bn = 25;           %noise Bandwidth(Hz)
dseta = 1;         %damping factor
kp = 1;            %phase gain
k0 = 1;            %VCO gain

%Computing the P-I loop-filter k1 and k2
wn=Bn*Ts/( dseta+1/(4*dseta) );       %natural frequency 
k1 = 4*dseta*wn/(1+2*dseta*wn+wn^2); %k1=0.1479;
k2 = 4*wn^2/(1+2*dseta*wn+wn^2);     %k2=0.0059;
% k2 = 0;
% Cuando k2 = 0, el loop filter no estaría integrando el error, por lo que
% pierde la información
% del pasado. El sistema que determina el comportamiento
% de la estabilización cambiaría sus coeficientes (Diap. 49) y su orden.
% Si se hace la analogía con un filtro continuo (Diap. 39), cuando k2 = 0
% se estarían modificando los polos y ceros del sistema, así como el orden
% (con k2 = 0, la expresión ya solo depende de s, no s^2). La respuesta ya
% no sería una amortiguación
% de orden 2, sino de orden 1 y puede beneficiar el tiempo de
% establecimiento (convergencia).

%% PLL LOOP
%Loop initial values
theta = zeros(1,N);      %theta initial values
accError=0;              %PLL memory

PLLout      = zeros(1, N);  %data for plots
errorVector = zeros(1, N);
for k=1:N-1  
  %NCO
  nco = exp(1j*(w0*(k-1) + theta(k)));
    
  %PED
  error = angle( r(k)*conj(nco) );
    
  %PLL control loop
  accError  = accError + error;
  theta(k+1)= theta(k) + k1*error + k2*accError;
  
  %data for plotting
  PLLout(k)  = nco;
  errorVector(k) = error;
end


%% plots
subplot(311)
plot(0:N-1, real(r), 'b', 'LineWidth', 2); grid; 
axis([0 80 -1.2 1.2])
title('input: Re\{r[k]\}')
xlabel('samples');

subplot(312)
plot(0:N-1, real(exp_in), 'b', 'LineWidth', 2); hold on
plot(0:N-1, real(PLLout), 'r', 'LineWidth', 2); grid; hold off
axis([0 80 -1.2 1.2])

title('input:Re\{exp_{in}\} (blue) vs. local replica: Re\{PLLout\} (red) ')
xlabel('samples');

subplot(313)
plot(0:N-1, errorVector, 'b', 'LineWidth', 2); grid; 
%axis([0 120 -1.2 1.2])
xlabel('samples'); title('error')



