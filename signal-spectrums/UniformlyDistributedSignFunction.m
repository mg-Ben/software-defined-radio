% Signal definition:
Ts = 1/100000; %Sample period
t = 0:Ts:0.1;
s = rand(1, length(t))*2 - 1;

title1='s(t)';
title2='S(f)';

plotspec(s,Ts, title1, title2, t)