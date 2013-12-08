figure('Name', 'performance_overhead_rel')
hold off
dt = 0.01;
x = [10, 50, 100, 500, 1000, 5000, 10000, 50000]*dt;

y1 = [0.1791, 0.3613, 0.5005, 0.8149, 0.8983, 0.9776, 0.9887, 0.9977];
y2 = [0.1664, 0.4676, 0.6336, 0.8951, 0.9445, 0.9884, 0.9942, 0.9988];
y3 = [0.1662, 0.4694, 0.6355, 0.8960, 0.9451, 0.9885, 0.9942, 0.9988];

l = [1, 1, 1, 1, 1, 1, 1, 1];

semilogx(x, y1, x, y2, x, y3, x, l)
title('Relative peformance overhead measurements of the runtime system')
legend('task\_repeats = 1', 'task\_repeats = 50', 'task\_repeats = 100', 2)
xlabel('task\_size (ms)'), ylabel('Relative amount of time spent')
