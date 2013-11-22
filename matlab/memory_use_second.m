figure('Name', 'dynamic_memory_use_second')
hold off
file2 = fopen('mem_nostm_opt.txt', 'r');
file3 = fopen('mem_stm_opt.txt', 'r');
file4 = fopen('mem_no_corout.txt', 'r');
data2 = fscanf(file2, '%f');
data3 = fscanf(file3, '%f');
data4 = fscanf(file4, '%f');

dt = 0.1;
t = [0:2490]*dt;

data2 = data2(1:length(t));
data3 = data3(1:length(t));
data4 = data4(1:length(t));

plot(t, data3, t, data4, t, data2)
title('Dynamic memory use')
legend('With RTS (Optimized)', 'With RTS (Optimized and no coroutines)', 'Without RTS')
xlabel('Time (s)'), ylabel('Memory use (KB)')
line([0 length(t)*dt], [68, 68], 'Color', 'm')

fclose(file2);
fclose(file3);
fclose(file4);

% values: task_size: 500, no_measurements = 10, task_repeats = 20, run_time
% = 300000ms

avg_nostm = mean(data2);
avg_stm_opt = mean(data3);
avg_no_corout = mean(data4);
averages = [avg_nostm, avg_stm_opt, avg_no_corout]

[max_nostm, i_nostm] = max(data2);
[max_stm_opt, i_stm_opt] = max(data3);
[max_no_corout, i_no_corout] = max(data4);

maxes = [max_nostm, max_stm_opt, max_no_corout]

index_nostm = i_nostm*dt;
index_stm_opt = i_stm_opt*dt;
index_no_corout = i_no_corout*dt;
indices = [index_nostm, index_stm_opt, index_no_corout]