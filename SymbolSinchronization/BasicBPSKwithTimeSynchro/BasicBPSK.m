%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Software Defined Radio (SDR)
% Basic BPSK Communication System with Symbol Synchronization
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc
%% Parameters
% Frame
header  = [1 0 1 0 0 1 1 1 0 1];            % Frame synchronization (included in txStream file)
synchroHeader = repmat([1; 0], 250, 1);     % Header for timing synchronization

% Symbols and samples
M = 15;                         % Samples per symbol = Oversamplig factor

% Modulation
fs = 10000; Ts = 1/fs;          % Sampling frequency, sampling period
fc = 2000;                      % Carrier frequency
phi = 0;                        % Carrier phase

% Channel
SNR = 50;                       % dB
%% BaseBand Tx - mapping + shaping filter
load txStream.mat
txStream_eff = [synchroHeader; txStream; zeros(100, 1)];

% Mapping
m = 2*txStream_eff-1;               % Mapping
NSymbols = length(m);           % Number of symbols

% Shaping filter
N = M*NSymbols;                 % Number of samples
me = zeros(1, N);
me(1:M:end) = m;                % Expansion
h  = hamming(M);                % Filtering
ms = filter(h,1,me);
%% Modulation
k = 0:N-1;                      % Sampling index
c = cos(2*pi*fc*k*Ts + phi);    % Carrier at freq fc
s = c.*ms;                      % Modulation
%% Channel
Ps = sum(s.^2)/N;               % Signal and noise powers
g = sqrt(Ps/10^(SNR/10));       % Noise gain
n = g*randn(1,N);               % Noise generation
r = s + n;                      % Corrupted signal
%% Demodulation (modulation + filtering)
k = 0:N-1;                      % Sampling index
c = cos(2*pi*fc*k*Ts + phi);   % Carrier at freq fc
r2 = c.*r;                      % Demodulation

% LPF
order = 30;                     % Order of the filter
fbe = [0 0.25 0.3 1];
damps=[1 1 0 0];                % LPF design
b = firpm(order, fbe, damps);   % impulse response of LPF
xf = filter(b, 1, r2);          % LPF the demodulated signal
%% Rx  - Matching Filtering + Timing Recovery + Slicer/Decisor
% Matching Filtering
x = filter(h, 1, xf); %x representa la señal de correlación

figure;
subplot(4, 1, 1)
stem(h)
subplot(4, 1, 2)
stem(ms(1:500))
subplot(4, 1, 3)
stem(xf(1:500))
subplot(4, 1, 4)
stem(x(1:500))

% Timing Recovery- Compressor
% z = x(30:M:end);                % by hand
z = timingRecoveryPLL(x, fs, M, 1, 25);

%Test example (for debugging):
% z = txStream(9:length(txStream))*2-1; %z_ideal:
% El mensaje txStream contiene una cabecera de sincronización adicional aña
% dida (101010...): concretamente, 8 bits añadidos: [10101010].
% El objetivo es que el z devuelto por timingRecoveryPLL no contenga esa
% parte (se puede descomentar
% el z ideal de la línea de arriba para comprobarlo)

% Slicer/Decisor
rxStream = zeros(size(z));
rxStream(z<0)  = 0;
rxStream(z>=0) = 1;

%% Unframe and Message Visualization - Frame synchronization + Presentation Layer
% Unframe
[rh, lags] = xcorr(2*rxStream-1, 2*header-1); %Rrh = rh((length(rh)+1)/2:end);
[maxim, ind] = max(rh);
ind_first_max = ind(1);
lag = lags(ind_first_max);
headStart = lag+1;

% Presentation layer
lengthMessagebin =  num2str(rxStream(headStart+length(header):headStart+length(header)+(24-1)));
lengthMessage = bin2dec(lengthMessagebin(:)'); % lengthMessage=44;

rxMsg = rxStream(headStart+length(header)+24:headStart+length(header)+24+8*(lengthMessage)-1);
disp(msg2text(rxMsg')); % ascii to text


