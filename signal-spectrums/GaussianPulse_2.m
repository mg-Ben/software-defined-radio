% Signal definition:
Ts = 1/10000; %Sample period
t = -2:Ts:2;
s = exp(-(t.^2));

title1='s(t)';
title2='S(f)';

plotspec(s, Ts, title1, title2, t)