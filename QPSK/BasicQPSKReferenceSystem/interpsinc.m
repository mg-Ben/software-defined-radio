function y=interpsinc(x, t, l)
% y=interpsinc(x, t, l,
% )
% interpolate to find a single point using the direct method
%        x = sampled data
%        t = place at which value desired
%        l = one sided length of data to interpolate
tnow=round(t);                       % create indices tnow=integer part
tau=t-round(t);                      % plus tau=fractional part
s_tau=sinc((-l:l)+tau);            % interpolating sinc at offset tau
x_tau=x(tnow+l:-1:tnow-l)*s_tau';  % interpolate the signal
y=x_tau;                      % the new sample

