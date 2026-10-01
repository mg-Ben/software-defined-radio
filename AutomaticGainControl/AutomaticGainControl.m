% agcvsfading.m: compensating for fading with an AGC
n=50000;                           % # steps in simulation
fc = 1e3;
fs = 8e3;
k=0:n-1;
r=5*cos(2*pi*fc*k'/fs);
A = 1/(10^(16/20));
env = ones(n, 1);
env(15001:35000) = A;
r=r.*env;                          % apply to raw input r[k]
a=zeros(1,n); a(1)=1;              % initialize AGC parameter
s=zeros(1,n);                      % initialize outputs
mu=0.001;                           % algorithm stepsize
% Bloque level computation: ver diapositiva 3 de xagc.pdf (se computa el
% módulo)
R = exp(-5);
for k=1:n-1
    s(k)=a(k)*r(k);                  % normalize by a to get s
    A = log(abs(s(k)));
    current_value=log(a(k))+mu*(-A + log(R));
    a(k+1)=exp(current_value);
end


% draw agcgrad.eps
subplot(3,1,2), plot(a,'g')        % plot AGC values
axis([0,length(r),0,1.5])
title('Adaptive gain parameter')
subplot(3,1,1), plot(r,'r')        % plot inputs and outputs
axis([0,length(r),-7,7])
title('Input r(k)')
subplot(3,1,3),plot(s,'b')
axis([0,length(r),-7,7])
title('Output s(k)')
xlabel('iterations')


