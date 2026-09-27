% Signal definition:
Ts = [1/50, 1/90, 1/100, 1/110, 1/200]; %Sample periods
f = 50; %Cosine frequency

for i=1:length(Ts)
    t = 0:Ts(i):1;
    s = cos(2*pi*f*t);
    figure;
    title1='s(t)';
    title2='S(f)';
    plotspec(s, Ts(i), title1, title2, t)
end

%Hay aliasing en las 3 primeras señales