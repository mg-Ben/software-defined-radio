function [zI, zQ] = derotationQPSK(ztI, ztQ)
%function [zI, zQ] = derotationQPSK(ztI, ZtQ)
%QPSK baseband phase derotation
%
%Input parameters
% ztI, ztQ: unsynchronized phase symbols
%Output parameters
% zI, zQ: synchronized phase  symbols
%

%PLL parameters
fs = 500; T=1/fs;  %sampling frequency
Bn = 25;            %noise Bandwidth(Hz)
kp = 1;            %phase gain
k0 = 1;            %VCO gain
dseta = 1;         %damping factor

%Loop-filter: k1 and k2
wn=Bn*T/( dseta+1/(4*dseta) );       %natural frequency 
k1 = 4*dseta*wn/(1+2*dseta*wn+wn^2); %k1
k2 = 4*wn^2/(1+2*dseta*wn+wn^2);     %k2

%PLL LOOP
zt= ztI + 1j*ztQ; %PLL input
zs=zeros(1, length(zt)-1); zs(1)=zt(1);
zsI=zeros(1, length(zt)-1);zsQ=zeros(1, length(zt)-1);
z=zeros(1, length(zt)-1);
theta=0; thetaplot = zeros(1, length(zt)-1);
accError =0;

constellation = sqrt(2)*[exp(1j*pi/4), exp(1j*3*pi/4), exp(-1j*3*pi/4), exp(-1j*pi/4)];

for i=1:length(zt)-1
    % For the first iteration, we assume we already have the initial zs
    %SLICER/DECISION
    % Compute the correlation with each constellation point:
    distance = zs(i)*conj(constellation);
    % In this case we can use |angle()| as an estimation for distance:
    distance = abs(angle(distance));
    [min_value, index_min] = min(distance);
    z(i) = constellation(index_min);

    %PED
    % error = angle(zs(i)*conj(z(i)));
    error = atan(imag(zs(i)*conj(z(i)))/real(zs(i)*conj(z(i))));
    
    %PLL control loop
    accError = accError + error;
    v = k1*error + k2*accError;
    thetaplot(i)=theta; %plot
    theta = v + theta;
    
    %NCO
    % zs(i+1) = zs(i+1);                      % correction
    NCO = exp(-1j*theta);
    zs(i+1) = zt(i+1)*NCO;
end
zI = real(z);
zQ = imag(z);


%plotting results
figure(2),
subplot(221); plot(ztI, ztQ,'b.')    % plot input constellation diagram
title('Input constellation diagram'); axis square; grid
subplot(222); plot(real(zs), imag(zs),'b.')     % plot output constellation diagram
title('Output constellation diagram'); grid; axis square; 
subplot(212); plot(thetaplot*360/(2*pi))
title('Derotation & Slicer'); ylabel('theta correction [º]')



