close all;
str='Transmit this text string'; % message to be transmitted
m=letters2pam(str); N=length (m) ; % 4−level signal of length N
M=10; mup=zeros(1,N*M); mup(1:M:N*M)=m; % oversample by M

transmitter_ps=hamming(M); % blip pulse of width M
x=filter(transmitter_ps, 1, mup);
x=x+1.0*randn(size(x));

%Ideal case
receiver_ps=transmitter_ps;
r=filter(receiver_ps, 1, x);
r_unnormalized=r*(max(m) / max(r));
% Obtain symbols:
received_symbols=r(M:M:N*M);
received_symbols=received_symbols * (max(m) / max(received_symbols));
% Se definen los niveles de cuantificación como:
% [-4, -2)
% [-2, 0)
% [0, 2)
% [2, 4)
ancho_intervalo = 2;
received_symbols=(floor((received_symbols+4)./ancho_intervalo)*ancho_intervalo+ancho_intervalo/2)-4;
%received_symbols = quantiz(received_symbols, [-2, 0, 2], [-3, -1, 1, 3]);
received_symbols(received_symbols>3)=3;
received_symbols(received_symbols<-3)=-3;
% Número de errores:
errors_perc=sum(m~=received_symbols)*100/length(m);
sprintf('Errores (porcentaje): %.3f',errors_perc)
figure;
subplot(4, 1, 1)
stem(m);
subplot(4, 1, 2)
stem(x);
subplot(4, 1, 3)
stem(r_unnormalized);
subplot(4, 1, 4)
stem(received_symbols);

%Try with another Pulse Shape on reception side:
receiver_ps=sin(0.1*pi*(0:M-1));
r=filter(receiver_ps, 1, x);
r_unnormalized=r*(max(m) / max(r));
% Obtain symbols:
received_symbols=r(M:M:N*M);
received_symbols=received_symbols * (max(m) / max(received_symbols));
% Se definen los niveles de cuantificación como:
% [-4, -2)
% [-2, 0)
% [0, 2)
% [2, 4)
ancho_intervalo = 2;
received_symbols=(floor((received_symbols+4)./ancho_intervalo)*ancho_intervalo+ancho_intervalo/2)-4;
%received_symbols = quantiz(received_symbols, [-2, 0, 2], [-3, -1, 1, 3]);
received_symbols(received_symbols>3)=3;
received_symbols(received_symbols<-3)=-3;
% Número de errores:
errors_perc=sum(m~=received_symbols)*100/length(m);
sprintf('Errores (porcentaje): %.3f',errors_perc)
figure;
subplot(4, 1, 1)
stem(m);
subplot(4, 1, 2)
stem(x);
subplot(4, 1, 3)
stem(r_unnormalized);
subplot(4, 1, 4)
stem(received_symbols);


%Try with another Pulse Shape on reception side:
receiver_ps=cos(0.1*pi*(0:M-1));
r=filter(receiver_ps, 1, x);
r_unnormalized=r*(max(m) / max(r));
% Obtain symbols:
received_symbols=r(M:M:N*M);
received_symbols=received_symbols * (max(m) / max(received_symbols));
% Se definen los niveles de cuantificación como:
% [-4, -2)
% [-2, 0)
% [0, 2)
% [2, 4)
ancho_intervalo = 2;
received_symbols=(floor((received_symbols+4)./ancho_intervalo)*ancho_intervalo+ancho_intervalo/2)-4;
%received_symbols = quantiz(received_symbols, [-2, 0, 2], [-3, -1, 1, 3]);
received_symbols(received_symbols>3)=3;
received_symbols(received_symbols<-3)=-3;
% Número de errores:
errors_perc=sum(m~=received_symbols)*100/length(m);
sprintf('Errores (porcentaje): %.3f',errors_perc)
figure;
subplot(4, 1, 1)
stem(m);
subplot(4, 1, 2)
stem(x);
subplot(4, 1, 3)
stem(r_unnormalized);
subplot(4, 1, 4)
stem(received_symbols);