figure('Name', 'dynamic_memory_use_opt')
hold off
file3 = fopen('mem_stm_gc600.txt', 'r');
file5 = fopen('test.txt', 'r');
data3 = fscanf(file3, '%f');
data5 = fscanf(file5, '%f');


dt = 0.1;
t = [0:2490]*dt;

data3 = data3(1:length(t));
data5 = data5(1:length(t));

plot(t, data3, t, data5)
title('Dynamic memory use')
legend('Step multiplier = 600', 'no class')
xlabel('Time (s)'), ylabel('Memory use (KB)')

fclose(file3);
fclose(file5);

% values: gc pause: 110, task_size: 500, EVENT_INTERVAL (task): 1ms,
% MEASURE_INTERVAL: 100ms, SEND_INTERVAL: 1s

avg400 = mean(data3);
avg600 = mean(data5);
averages = [avg400, avg600]

[max400, i400] = max(data3);
[max600, i600] = max(data5);

maxes = [max400, max600]

index400 = i400*dt;
index600 = i600*dt;
indices = [index400, index600]