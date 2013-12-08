figure('Name', 'performance_overhead_abs2')
hold off
dt = 0.01;
x = [10, 50, 100, 500, 1000, 5000, 10000, 50000]*dt;

dt2 = 111/235;
y1 = [1114, 222, 111, 23, 11, 2, 1, 0]*dt2;
y2 = [566, 113, 57, 11, 6, 1, 1, 0]*dt2;
y3 = [561, 112, 56, 11, 6, 1, 1, 0]*dt2;

semilogx(x, y1, x, y2, x, y3)
title('Performance overhead measurements of runtime system')
legend('task\_repeats = 1', 'task\_repeats = 50', 'task\_repeats = 100')
xlabel('task\_size (ms)'), ylabel('Time (\mus) spent on overhead for each 100 \mus of useful work')