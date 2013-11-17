hold off
file1 = fopen('mem200.txt', 'r');
%file2 = fopen('mem300.txt', 'r');
%file3 = fopen('mem400.txt', 'r');
data1 = fscanf(file1, '%f');
%data2 = fscanf(file2, '%f');
%data3 = fscanf(file3, '%f');

dt = 0.5;
t = [0:length(data1)-1]*dt;

%hold on
plot(t, data1)
title('Dynamic memory use')
xlabel('Time (s)'), ylabel('Memory use (KB)')