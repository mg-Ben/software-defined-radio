function xs = timingRecoveryPLL(x, fs, M, dseta, Bn)
%xs = timingRecoveryPLL(x)
%Timing synchronization for the ideal system
%
%Input parameters
% x: Matching filter output
% fs: sampling frequency
% M: Oversampling factor or samples per Symbol
% dseta: PLL parameter. Damping factor 
% Bn: PLL parameter. Noise BandWidth
%
%Output parameters
% xs: Decimated output samples (one per symbol)

% PLL constants
fs = fs/M; T = 1/fs;  % symbol sampling frequency
% Computing the P-I loop-filter constants; k1 and k2
wn = Bn*T/(dseta+1/(4*dseta));       % natural frequency 
k1 = 4*dseta*wn/(1+2*dseta*wn+wn^2); % k1
k2 = 4*wn^2/(1+2*dseta*wn+wn^2);     % k2
% Se puede especificar el funcionamiento del bucle con los parámetros de
% arriba, pero no es necesario: se puede hacer también únicamente con mu y
% actualizando el valor de tao.
%loop initialitations
tau = 0; i = 0;

% PLL loop
while tnow < length(x) - lside-tau   % run iteration
  

  
  tnow = tnow+M; 
  tausave(i) = tau;                  % save for plotting
end
% plot results

