% Marker A:
M = [1, 1, 1, 1, 1, 1, 1];
binary_data_sequence=[1, -1, 1, 1, -1, -1, -1, 1, M, 1, -1, 1];
% Correlation:
correlation_A=zeros(1, length(binary_data_sequence)-(length(M)-1));
for i=1:length(correlation_A)
    correlation_A(i)=sum(binary_data_sequence(i:i+length(M)-1).*M);
end

% Marker B:
M = [1, 1, 1, -1, -1, 1, -1];
binary_data_sequence=[1, -1, 1, 1, -1, -1, -1, 1, M, 1, -1, 1];
% Correlation:
correlation_B=zeros(1, length(binary_data_sequence)-(length(M)-1));
for i=1:length(correlation_B)
    correlation_B(i)=sum(binary_data_sequence(i:i+length(M)-1).*M);
end