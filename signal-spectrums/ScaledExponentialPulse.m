% Signal definition:
Ts = 1/10000; %Sample period
t = 0:Ts:10;
s = 5*exp(-t);

title1='s(t)';
title2='S(f)';

plotspec(s, Ts, title1, title2, t)