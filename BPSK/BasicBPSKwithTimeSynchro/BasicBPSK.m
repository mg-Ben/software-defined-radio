%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Design of Communication Systems and Equipment  
% 
%
%
%The basic BPSK Communication System. (full version).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clf; clc


%% Parameters
%Frame
header  = [1 0 1 0 0 1 1 1 0 1];       %Frame synchronization (included in txStream file)
synchroHeader= zeros(1,500);           %Add this header for
synchroHeader(1:2:end)=ones(1,250);    %timing synchronization

% Symbols and samples
M = 15;                % Samples per symbol=Oversamplig factor

% Modulation
fs=10000; Ts =1/fs;    % Sampling frequency
fc=2000;               % Carrier frequency
phi=0;                 % Carrier phase

% Channel
SNR=50 ;               %dB


%% BaseBand Tx - mapping + shaping filter  
load txStream.mat
txStream = [synchroHeader'; txStream];

%mapping
m  = 2*txStream-1;    %mapping
NSymbols = length(m); %number of symbols

%shaping filter
N=M*NSymbols;         %number of samples
me = zeros(1, N);
me(1:M:end) = m;     %expansion 
h  = hamming(M);     %filtering
ms = filter(h,1,me);


%% Modulation
k = 0:N-1;                      % sampling index
c=cos( 2*pi*fc*k*Ts + phi );    % carrier at freq fc
s=c.*ms;                        % modulation


%% Channel - adding noise  
n = randn(1,N);                   % noise generation
Ps = sum(s.^2)/N;                 % signal and noise powers
Pn = sum(n.^2)/N;
g = sqrt( Ps/(Pn*10^(SNR/10)) );  % noise gain
r = s + g*n;                      % corrupted signal


%% Demodulation (modulation + filtering)
k = 0:N-1;               % sampling index
c=cos( 2*pi*fc*k*Ts + phi );   % carrier at freq fc
r2=c.*r;                        % modulation

% LPF
order=30;                            % Order of the filter
fbe=[0 0.25 0.3 1]; damps=[1 1 0 0]; % LPF design
b=firpm(order,fbe,damps);            % impulse response of LPF
xf = filter(b,1,r2);                 % LPF the demodulated signal


%% Rx  - Matching Filtering + Timing Recovery + Slicer/Decisor
%Matching Filtering
x = filter(h,1,xf);

%Timing Recovery- Compressor
%z=x(30:M:end);   
z=timingRecoveryPLL(x, fs, M, dseta, Bn);


% Slicer/Decisor
rxStream = zeros(size(z));
rxStream(z<0)  = 0;
rxStream(z>=0) = 1;


%% Unframe and Message Visualization - Frame synchronization + Presentation Layer   
%Unframe
rh = xcorr(2*rxStream-1, 2*header-1); Rrh = rh( (length(rh)+1)/2:end );
[maxim, ind] = max(Rrh); headStart = ind(1); %headStart=9

% Presentation layer
lengthMessagebin =  num2str( rxStream(headStart+10:headStart+10+(24-1)) );
lengthMessage    = bin2dec(lengthMessagebin(:)'); %lengthMessage=44;

rxMsg = rxStream(headStart+10+24:headStart+10+24+8*(lengthMessage)-1 );
disp(msg2text(rxMsg')); %ascii to text

