%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Design of Communication Systems and Equipment (DCSE)                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cleaning
close all; clear all;
%% Parameters 
FRAME_HDR = [1, 0, 1, 0, 0, 1, 1, 1, 0, 1]';   % frame header
FS = 10e6;                  % sampling frequency (Hz)
TS = 1/FS;                  % sampling period (s)
M = 15;                     % oversampling factor
FC = 1e6;                   % carrier frequency (Hz)
PHIC = 0;                   % carrier phase (rad)
SNR = 30;                   % channel white gaussian noise (dB)
%% Tx
% message frame
tx_msg = 'This is a test message';
tx_frame = make_frame(FRAME_HDR, tx_msg);
figure;
title('tx_frame')
stem(0:length(tx_frame)-1, tx_frame);

% baseband signal
ps = hamming(M); %%% Change this line %%%
ms = make_signal(tx_frame, M, ps);
figure;
stem(1:20*M, ms(1:20*M));
title('ms[k]')

% modulate the baseband signal
s = modulate(ms, FS, FC, PHIC);
figure;
plot(0:length(s)-1, s);
title('s[k]')

%% Channel
% corrupted by AWGN received signal
r = add_noise(s, SNR);
figure;
plot(0:length(s)-1, s); hold on;
plot(0:length(r)-1, r);
title('r[k]')
%% Rx
% demodulation filter
order = 32;
ff = [0 0.2 0.3 1];
fa = [1 1 0 0];
lpf = firpm(order, ff, fa);

% demodulate the received signal
phi = 0;
rd = demodulate(r, FS, FC, lpf, phi);
figure;
stem(1:20*M, rd(1:20*M))
title('rd[k]')
% get the received frame
rx_frame = get_frame(rd, M, ps, order);
figure;
subplot(2, 1, 1)
stem(0:length(tx_frame)-1, tx_frame);
subplot(2, 1, 2)
stem(0:length(rx_frame)-1, rx_frame);

% extract the message
rx_frame=rx_frame';
[rx_msg, err] = get_msg(rx_frame, FRAME_HDR);

% decode the message
if err
    disp('Error: No valid message in the received frame.')
else
    disp(msg2text(rx_msg));
end
%% 
function frame = make_frame(header, msg)
% Encodes the message and builds the frame.
%
% inputs:
%   header: the frame header (column vector of bits)
%	msg: the msg (character string)
% output:
%   frame: bits to transmit (column vector)

% message length encoded in one byte
msg_len = str2num(reshape(dec2bin(length(msg), 8), [], 1)); %#ok

% message encoding to bits using 8 bit-ASCCI code
msg_bits = str2num(reshape(dec2bin(double(msg), 8).', [], 1)); %#ok 

% frame to be transmitted
frame = [header; msg_len; msg_bits];
end
%%
function y = make_signal(frame, M, pulse)
% Builds the baseband signal from the frame in bits. It can be divided in
% two parts: 1) mapping from bits to symbols and 2) pulse shaping the
% symbols with a pulse.
%
% inputs:
%   frame: column vector of frame bits
%   M: oversampling factor (number of samples per symbol)
%   pulse: shaping pulse 
% output:
%   y: baseband signal as column vector
%    
% mapping: change 0's for -1, leave 1's unchanged
%%% Your code here %%%
ms = zeros(1, length(frame)*M);
% 2-PAM dictionary:
PAM_dictionary_keys = configureDictionary("int64", "int64");
PAM_dictionary_keys(0) = -1;
PAM_dictionary_keys(1) = 1;

% pulse shaping: (expansion + filtering)
for i=1:length(frame)
    ms((i-1)*M+1)=PAM_dictionary_keys(frame(i));
end
ms = filter(pulse, 1, ms);

% add some zeros at the end of the signal (for correlation)
ms = [ms, zeros(1, 10*M)];

% apply shaping pulse 
%%% Your code here %%%
y = ms;
end
%%
function s = modulate(x, fs, fc, phi)
% Modulates the baseband signal x to the carrier frequency.
%
% inputs:
%   x: input signal (column vector)
%   fs: sampling frequency
%   fc: carrier frequency
%   phi: carrier phase
% outputs:
%   s: modulated signal (column vector)
%
% modulation
discrete_domain = 0:length(x)-1;
carrier_signal=cos(2*pi*fc/fs*discrete_domain + phi);

s = x.*carrier_signal;
end
%%
function y = add_noise(x, snr)
% Simulates channel corruption by adding white gaussian noise to the signal
% inputs:
%   x: signal (column vector)
%   snr: desired signal to noise ratio
% output:
%   y: corrupted signal (column vector)
%

% signal power
signal_power=pow(x);

% noise
snr_nat_power = 10^(snr/10);
noise_power = signal_power/snr_nat_power;
noise_sigma = sqrt(noise_power);
% corruption
n = noise_sigma*randn(1, length(x));
y = x+n;
end
%%
function y = demodulate(r, fs, fc, flt, phi)
% Demodulates the pass signal r to baseband.
%
% inputs:
%   r: input signal (column vector)
%   fs: sampling frequency
%   fc: carrier frequency
% outputs:
%   y: demodulated signal (column vector)
%
% demodulation
discrete_domain = 0:length(r)-1;
carrier_signal=cos(2*pi*fc/fs*discrete_domain + phi);

s = r.*carrier_signal;
% filter
x = filter(flt, 1, s);
y = x;
end
%%
function frame = get_frame(x, M, ps, N)
% Samples the signal in symbols chunks and make a decision about the
% encoded bit. It can be divided in two parts: matched filtering and 
% symbol to bit decision. 
% inputs:
%   z: signal (column vector)
%   M: oversampling factor (number of samples per symbol)
%   ps: pulse shape
%   N: length of the downconversion LPF
% outputs:
%   frame: received bits (column vector)
%
% matched filtering
xf = filter(ps, 1, x);

% symbol sampling
% En este caso, se elige el primer instante de muestreo
% en base a la señal recibida (de manera estimada), ya que
% no se puede predecir con exactitud el retardo del LPF
% que hay detrás del oscilador del demodulador
z = xf(31:M:length(xf));
% decision
% En este caso (BPSK), se tienen dos regiones de decisión:
% > 0 y < 0 (no es necesario cuantificar estrictamente)
frame = (sign(z)+1)./2;
end
%%
function [msg, err] = get_msg(frame, header)
% Extracts the message from the received frame.
% inputs:
%   frame: received bit frame (column vector)
%   header: message header (column vector)
% outputs:
%   msg: decoded message (character string)
%
err = 0;
% make frame and header bipolar
str = 2*frame-1;
hdr = 2*header-1;cd 
% locate header
[sh, lags] = xcorr(str, hdr);
[m, idx] = max(sh);
if round(m) < length(header)
    err = 1;
    msg = [];
    return
end
% extract header
cnt = lags(idx);
lh = length(header);
rx_header = frame(cnt+(1:lh));
if any(rx_header ~= header)
    err = 1;
    msg = [];
    return
end
cnt = cnt + lh;
% extract message length
msg_len_bits = frame(cnt+(1:8));
msg_len = bin2dec(num2str(msg_len_bits'));
cnt = cnt + 8;
% extract message
if cnt+8*msg_len > length(frame)
    err = 1;
    msg = [];
    return
end
msg = frame(cnt+(1:8*msg_len));

end
%% 
function text = msg2text(msg)
% Converts a bit-stream into an ASCII character string
text = char(bin2dec(reshape(num2str(msg), 8, []).').');
end
