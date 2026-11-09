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

%loop initialitations
tau = 0; i = 0;

tnow = ceil(M/2);
delta = 0.1;
mu_2delta = 0.05;

xs = zeros(1, ceil(length(x)/M));
tausave = zeros(1, ceil(length(x)/M));
accError = 0;

% PLL loop
while tnow < length(x) - delta-tau   % run iteration
    i=i+1;
    xs(i)=interpsinc(x,tnow+tau,1);   % interp value at tnow+tau
    x_deltap=interpsinc(x,tnow+tau+delta,1); % value to right
    x_deltam=interpsinc(x,tnow+tau-delta,1); % value to left
    dx=x_deltap-x_deltam;             % numerical derivative

    error = mu_2delta*dx*xs(i);
    accError = accError + error;       % alg update (energy)
    v = error*k1 + accError*k2;
    tau = tau + v;                    % update timing phase

    tnow = tnow+M; 
    tausave(i) = tau;                  % save for plotting
end
% plot results
figure;
subplot(2, 1, 1)
plot(xs, 'b.')
subplot(2, 1, 2)
plot(tausave)