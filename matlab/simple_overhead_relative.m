figure('Name', 'performance_overhead_rel')
hold off
dt = 0.01;
x = [10, 50, 100, 500, 1000, 5000, 10000, 50000]*dt;

y1 = [];
y2 = [];
y3 = [];

l = [1, 1, 1, 1, 1, 1, 1, 1];

semilogx(x, y1, x, y2, x, y3, x, l)
title('Relative peformance overhead measurements of the runtime system')
legend('task\_repeats = 1', 'task\_repeats = 50', 'task\_repeats = 100', 2)
xlabel('task\_size (ms)'), ylabel('Relative amount of time spent')
