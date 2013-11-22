figure('Name', 'dynamic_memory_use_first')
hold off
file1 = fopen('mem_stm_nonopt.txt', 'r');
file2 = fopen('mem_nostm.txt', 'r');
file3 = fopen('mem_stm_opt.txt', 'r');
file4 = fopen('mem_no_corout.txt', 'r');
file5 = fopen('mem_stm_encap.txt', 'r');
data1 = fscanf(file1, '%f');
data2 = fscanf(file2, '%f');
data3 = fscanf(file3, '%f');
data4 = fscanf(file4, '%f');
data5 = fscanf(file5, '%f');

%data2 = data2(1:length(data1));

dt = 0.1;
t1 = [0:length(data1)-1]*dt;
t2 = [0:length(data2)-1]*dt;
t3 = [0:length(data3)-1]*dt;
t4 = [0:length(data4)-1]*dt;
t5 = [0:length(data5)-1]*dt;

%plot(t1, data1, t2, data2)
plot(t1, data1, t2, data2, t3, data3, t4, data4, t5, data5)
title('Dynamic memory use')
%legend('With RTS', 'Without RTS')
legend('With RTS', 'Without RTS', 'With RTS (optimized)', 'With RTS (no coroutines)', 'With RTS and encapsulation')
xlabel('Time (s)'), ylabel('Memory use (KB)')

fclose(file1);
fclose(file2);
fclose(file3);
fclose(file4);
fclose(file5);

% values: task_size: 500, no_measurements = 10, task_repeats = 20, run_time
% = 300000ms

avg_stm_nonopt = mean(data1);
avg_nostm = mean(data2);
avg_stm_opt = mean(data3);
avg_no_corout = mean(data4);
avg_stm_encap = mean(data5);
averages = [avg_stm_nonopt, avg_nostm, avg_stm_opt, avg_no_corout, avg_stm_encap]

[max_stm_nonopt, i_stm_nonopt] = max(data1);
[max_nostm, i_nostm] = max(data2);
[max_stm_opt, i_stm_opt] = max(data3);
[max_no_corout, i_no_corout] = max(data4);
[max_stm_encap, i_stm_encap] = max(data5);

maxes = [max_stm_nonopt, max_nostm, max_stm_opt, max_no_corout, max_stm_encap]

index_stm_nonopt = i_stm_nonopt*dt;
index_nostm = i_nostm*dt;
index_stm_opt = i_stm_opt*dt;
index_no_corout = i_no_corout*dt;
index_stm_encap= i_stm_encap*dt;
indices = [index_stm_nonopt, index_nostm, index_stm_opt, index_no_corout, index_stm_encap]