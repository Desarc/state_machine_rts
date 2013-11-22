figure('Name', 'dynamic_memory_use_nostm')
hold off

file1 = fopen('mem_nostm_gc200.txt', 'r');
file2 = fopen('mem_nostm_gc400.txt', 'r');
file3 = fopen('mem_nostm_gc600.txt', 'r');
file4 = fopen('mem_nostm_gc800.txt', 'r');
file5 = fopen('mem_nostm_gc1000.txt', 'r');

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
legend('Step multiplier = 200 (default)', 'Step multiplier = 400', 'Step multiplier = 600', 'Step multiplier = 800', 'Step multiplier = 1000')
xlabel('Time (s)'), ylabel('Memory use (KB)')

fclose(file1);
fclose(file2);
fclose(file3);
fclose(file4);
fclose(file5);

% values: gc pause: 110, task_size: 500, no_measurements = 10, task_repeats = 20, run_time = 3000

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