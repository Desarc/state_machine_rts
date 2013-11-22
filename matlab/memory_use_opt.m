figure('Name', 'dynamic_memory_use_opt')
hold off
file1 = fopen('mem_stm_gc200.txt', 'r');
file2 = fopen('mem_stm_gc400.txt', 'r');
file3 = fopen('mem_stm_gc600.txt', 'r');
file4 = fopen('mem_stm_gc800.txt', 'r');
file5 = fopen('mem_stm_gc1000.txt', 'r');
data1 = fscanf(file1, '%f');
data2 = fscanf(file2, '%f');
data3 = fscanf(file3, '%f');
data4 = fscanf(file4, '%f');
data5 = fscanf(file5, '%f');


dt = 0.1;
t = [0:2490]*dt;

data1 = data1(1:length(t));
data2 = data2(1:length(t));
data3 = data3(1:length(t));
data4 = data4(1:length(t));
data5 = data5(1:length(t));

plot(t, data1, t, data2, t, data3, t, data4, t, data5)
title('Dynamic memory use')
legend('Step multiplier = 200 (default)', 'Step multiplier = 400', 'Step multiplier = 600', 'Step multiplier = 800', 'Step multiplier = 1000')
xlabel('Time (s)'), ylabel('Memory use (KB)')

fclose(file1);
fclose(file2);
fclose(file3);
fclose(file4);
fclose(file5);

% values: gc pause: 110, task_size: 500, EVENT_INTERVAL (task): 1ms,
% MEASURE_INTERVAL: 100ms, SEND_INTERVAL: 1s

avg200 = mean(data1);
avg300 = mean(data2);
avg400 = mean(data3);
avg500 = mean(data4);
avg600 = mean(data5);
averages = [avg200, avg300, avg400, avg500, avg600]

[max200, i200] = max(data1);
[max300, i300] = max(data2);
[max400, i400] = max(data3);
[max500, i500] = max(data4);
[max600, i600] = max(data5);

maxes = [max200, max300, max400, max500, max600]

index200 = i200*dt;
index300 = i300*dt;
index400 = i400*dt;
index500 = i500*dt;
index600 = i600*dt;
indices = [index200, index300, index400, index500, index600]