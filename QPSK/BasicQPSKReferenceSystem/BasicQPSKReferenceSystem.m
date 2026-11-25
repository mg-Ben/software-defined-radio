%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Design of Communication Systems and Equipment
% file: BasicQPSKReferenceSystem.m
%
% System with QPSK modulation and that includes the following files: 
%   - PLL timing synchronization: timingRecoveryQPSK.m
%   - Fractional delay interpolation: interpsinc.m
%   - PLL derotation and slicer: derotationQPSK.m
%   - Disambiguation: disambiguationQPSK.m
%   - input data. txStream.mat
%   - msg2text. ascii code to text 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;

%% Parameters
%frame
synchroHeader=repmat([1 0], 1, 260);                % Alternating bits for timing recovery
rng(0); disambiguationHeader = round(rand(1,50));  % Remove the synchronization phase ambiguity
frameHeader     = [1 0 1 0 0 1 1 1 0 1];    % frame Sychronization (included in txStream file)

% Symbols
M = 15;              % Samples per symbol=Oversamplig factor

% Modulation
fs=10000; Ts =1/fs;            % Sampling frequency
fc=2000;                       % Carrier frequency
phi=25*2*pi/360; deltafc=0;           % Carrier phase [rad] & frequency error

% Channel
SNR=30;               %dB

%% Baseband Tx - mapping + shaping filter
% frame
load txStream.mat           % Loading the bits
txStream = [synchroHeader'; disambiguationHeader'; txStream; zeros(100,1)]; %zeros are added                                                    %compensate the                                                      %filters

% QPSK mapping
mI = 2*txStream(1:2:end)-1;
mQ = 2*txStream(2:2:end)-1;
NSymbols = length(mI);   %Number of Symbols


%Shaping filtering - oversampling + pulse shaping
% Oversampling by M
meI=zeros(1, M*NSymbols);      
meI(1:M:end)= mI;        % Oversampling the message vector by M
meQ=zeros(1, M*NSymbols);      
meQ(1:M:end)= mQ;        % Oversampling the message vector by M

% Pulse shaping
ps=hamming(M);                     % hamming pulse of length M
msI=filter(ps,1,meI);              % convolve pulse shape with data
msQ=filter(ps,1,meQ);



%% Modulator
k = 0:M*NSymbols-1;                         % sampling index of length length(ms)
c=exp( 1i*(2*pi*(fc+deltafc)*k*Ts+phi) );   % carrier at freq fc
s=real( c.*(msI + 1j*msQ) );     % modulation


%% Channel - adding noise
Ps    = sum(s.^2)/length(s);    % Power of the  transmitted signal

% generate noise signal
sigma = sqrt(Ps/(10^(SNR/10))); % Calculate the sigma of the noise
n = sigma*randn(size(s));
r = s + n;                  % received noisy signal


%% Demodulation - modulation + filtering
c2  = exp( -1j*(2*pi*fc*k*Ts) );     % synchronized cosine for mixing
r2  = r.*c2;                         % demod received signal
r2I = real(r2);
r2Q = imag(r2);

% LPF
order=30;                              % Order of the filter
fbe = [0 0.25 0.3 1]; damps=[1 1 0 0]; % LPF design
b   = firpm(order,fbe,damps);          % impulse response of LPF
xfI = filter(b,1,r2I);                 % LPF the demodulated signal
xfQ = filter(b,1,r2Q);


%% Receiver - Matching filtering + Timing Recovery + Phase recovery and slicer +
%             + Phase Ambiguity Correction
%matching filter
xI=filter(ps,1,xfI); 
xQ=filter(ps,1,xfQ); 

% timing recovery
dseta = 1; Bn=0.05;
[ztI, ztQ] = timingRecoveryQPSK(xI, xQ, M,dseta,Bn);

% Slicer
zI  = zeros( size(ztI) ); zI(ztI>0) = 1;
zQ  = zeros( size(ztQ) ); zQ(ztQ>0) = 1;
rxStream=zeros( 1,2*length(zI) ); 
rxStream(1:2:end) = zI;
rxStream(2:2:end) = zQ;

% Phase recovery and slicer
[zI, zQ] = derotationQPSK(ztI, ztQ);

% Phase ambiguity correction
rxStream = disambiguationQPSK(zI, zQ, disambiguationHeader);


%% Unframe and Message Visualization - frame synchronization + Presentation Layer
rh = xcorr(2*rxStream-1, 2*frameHeader-1); Rrh = rh( (length(rh)+1)/2:end );
[maxim, ind] = max(Rrh); headStart = ind(1); 

% Presentation layer
lengthMessagebin = num2str( rxStream(headStart+10:headStart+10+(24-1)) );
lengthMessage    = bin2dec(lengthMessagebin(:)');

rxMsg = rxStream(headStart+10+24:headStart+10+24+8*(lengthMessage)-1 );
disp(msg2text(rxMsg')); %ascii to text
