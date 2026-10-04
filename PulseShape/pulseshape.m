str='Transmit this text string'; % message to be transmitted
m=letters2pam(str); N=length (m) ; % 4−level signal of length N
M=10; mup=zeros(1,N*M); mup(1:M:N*M)=m; % oversample by M

transmitter_ps=hamming(M); % blip pulse of width M
x=filter(transmitter_ps, 1, mup);

%Ideal case
receiver_ps=transmitter_ps;
r=filter(receiver_ps, 1, x);

r_normalized=r./max(r);
figure;
subplot(2, 1, 1); stem(x);
subplot(2, 1, 2); stem(r);

%Try with another Pulse Shape on reception side:
receiver_ps=sin(0.1*pi*(0:M-1));
r=filter(receiver_ps, 1, x);
figure;
subplot(2, 1, 1)
stem(x);
subplot(2, 1, 2)
stem(r);
% Obtain symbols:
received_symbols=r(1:M:N*M);
received_symbols=received_symbols * (max(m) / max(received_symbols));
received_symbols = quantiz(received_symbols, [-2, 0, 2], [-3, -1, 1, 3]);

% Número de errores:
sum(m~=received_symbols)
figure;
subplot(2, 1, 1)
stem(m);
subplot(2, 1, 2)
stem(received_symbols);


%Try with another Pulse Shape on reception side:
receiver_ps=cos(0.1*pi*(0:M-1));
r=filter(receiver_ps, 1, x);
figure;
subplot(2, 1, 1)
stem(x);
subplot(2, 1, 2)
stem(r);