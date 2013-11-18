figure('Name', 'dynamic_memory_use_non_opt')
hold off
file1 = fopen('mem_gc200_non_opt.txt', 'r');
file2 = fopen('mem_gc300_non_opt.txt', 'r');
file3 = fopen('mem_gc400_non_opt.txt', 'r');
file4 = fopen('mem_gc500_non_opt.txt', 'r');
file5 = fopen('mem_gc600_non_opt.txt', 'r');
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

% values: gc pause: 110, task_size: 500, EVENT_INTERVAL (task): 1ms,
% MEASURE_INTERVAL: 100ms, SEND_INTERVAL: 1s

[max200, i200] = max(data1);
[max300, i300] = max(data2);
[max400, i400] = max(data3);
[max500, i500] = max(data4);
[max600, i600] = max(data5);

max200
index200 = i200*dt
max300
index00 = i300*dt
max400
index400 = i400*dt
max500
index500 = i500*dt
max600
index600 = i600*dt