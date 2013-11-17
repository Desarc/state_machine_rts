figure('Name', 'dynamic_memory_use')
hold off
file1 = fopen('mem200.txt', 'r');
file2 = fopen('mem300.txt', 'r');
file3 = fopen('mem400.txt', 'r');
file4 = fopen('mem500.txt', 'r');
file5 = fopen('mem600.txt', 'r');
data1 = fscanf(file1, '%f');
data2 = fscanf(file2, '%f');
data3 = fscanf(file3, '%f');
data4 = fscanf(file4, '%f');
data5 = fscanf(file5, '%f');

dt = 0.1;
t1 = [0:length(data1)-1]*dt;
t2 = [0:length(data2)-1]*dt;
t3 = [0:length(data3)-1]*dt;
t4 = [0:length(data4)-1]*dt;
t5 = [0:length(data5)-1]*dt;

plot(t1, data1, t2, data2, t3, data3, t4, data4, t5, data5)
title('Dynamic memory use')
legend('Step multiplier = 200 (default)', 'Step multiplier = 300', 'Step multiplier = 400', 'Step multiplier = 500', 'Step multiplier = 600')
xlabel('Time (s)'), ylabel('Memory use (KB)')

fclose(file1);
fclose(file2);
fclose(file3);
fclose(file4);
fclose(file5);