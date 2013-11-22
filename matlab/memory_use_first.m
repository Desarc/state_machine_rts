figure('Name', 'dynamic_memory_use_first')
hold off
file1 = fopen('mem_stm_nonopt.txt', 'r');
file2 = fopen('mem_nostm_nonopt.txt', 'r');
data1 = fscanf(file1, '%f');
data2 = fscanf(file2, '%f');

dt = 0.1;
t = [0:2490]*dt;

data1 = data1(1:length(t));
data2 = data2(1:length(t));

plot(t, data1, t, data2)
title('Dynamic memory use')
legend('With RTS', 'Without RTS')
xlabel('Time (s)'), ylabel('Memory use (KB)')
line([0 length(t)*dt], [68, 68], 'Color', 'm')

fclose(file1);
fclose(file2);

% values: task_size: 500, no_measurements = 10, task_repeats = 20, run_time
% = 300000ms

avg_stm_nonopt = mean(data1);
avg_nostm = mean(data2);
averages = [avg_stm_nonopt, avg_nostm]

[max_stm_nonopt, i_stm_nonopt] = max(data1);
[max_nostm, i_nostm] = max(data2);

maxes = [max_stm_nonopt, max_nostm]

index_stm_nonopt = i_stm_nonopt*dt;
index_nostm = i_nostm*dt;
indices = [index_stm_nonopt, index_nostm]