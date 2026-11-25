function [zI, zQ]=timingRecoveryQPSK(xI, xQ, M, dseta, Bn)
%function xs=timingRecoveryQPSK(xI, xQ, M, dseta, Bn),
%Timing synchronization for the ideal system
%
%Input parameters
% x: Matching filter output
% M: Oversampling factor or samples per Symbol
% dseta: PLL parameter. Damping factor 
% Bn: PLL parameter. Noise BandWidth
%
%Output parameters
% zI, zQ: Decimated output samples (one per symbol)
%

x = sqrt( xI.^2 + xQ.^2 );  %PLL input
                            %signal magnitude

%Loop filter: k1 and k2
wn=Bn/( dseta+1/(4*dseta) );       %natural frequency 
k1 = 4*dseta*wn/(1+2*dseta*wn+wn^2); %k1
k2 = 4*wn^2/(1+2*dseta*wn+wn^2);     %k2

%PLL LOOP
lside = 50;            % initialization for
tnow  = lside*M+1;     % interpsinc

tau=0; 
tauplot=zeros(size(x)); %plot

delta=0.1;     % derivative
accError=0;    % PLL
xs=zeros(1,length(x)-lside*(M+1));
zI=zeros(1,length(x)-lside*(M+1));
zQ=zeros(1,length(x)-lside*(M+1));
i=1; % loop index
while tnow<length(x)-lside         % run iteration
 
  %sampling the symbol. (1 sample/symbol)
  xs(i)    = interpsinc(x,tnow+tau,lside);   %x[k] =x(kT+tau)
  zI(i)    = interpsinc(xI,tnow+tau,lside);  % zI[k]=zI(kT+tau) 
  zQ(i)    = interpsinc(xQ,tnow+tau,lside);  % zQ[k]=zQ(kT+tau) 

  %TED: OP
  x_deltap = interpsinc(x,tnow+tau+delta, lside);  % x(kT+tau+delta)
  x_deltam = interpsinc(x,tnow+tau-delta, lside);  % x(kT+tau-delta)
  dx       = x_deltap-x_deltam;                    % dx[k]/dtau. numerical derivative
  error    = dx*xs(i);                
  
  %PLL control loop
  accError = accError + error;
  tau = tau + k1*error + k2*accError;
  
  %NCO
  tnow=tnow+M;

  tauplot(i)=tau;  %plot  
  
  i=i+1; %index increment
end

%plotting results
figure(1),
subplot(2,2,1), plot(xI, xQ,'.')        % plot input constellation diagram
title('Input constellation diagram'); axis square; grid
subplot(2,2,2), plot(zI, zQ,'.')        % plot output constellation diagram
title('Output constellation diagram'); axis square; grid
subplot(2,1,2), plot(tauplot(1:i-2))        % plot tau evolution
title('Timing recovery')
ylabel('tau estimates'), xlabel('iterations')

