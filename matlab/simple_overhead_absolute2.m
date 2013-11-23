figure('Name', 'simple_overhead_abs2')
hold off
dt = 0.01;
x = [10, 50, 100, 500, 1000, 5000, 10000, 50000]*dt;

dt2 = 100/235;
y1 = [1113, 201, 96, 11, 1, -8, -9, -9]*dt2;
y2 = [565, 92, 41, 1, -5, -9, -9, -10]*dt2;
y3 = [526, 91, 41, 0, -5, -9, -9, -10]*dt2;
y4 = [543, 90, 40, 0, -5, -9, -9, -10]*dt2;

semilogx(x, y1, x, y2, x, y3, x, y4)
title('Performance overhead measurements of runtime system')
legend('task\_repeats = 1', 'task\_repeats = 50', 'task\_repeats = 100', 'task\_repeats = 500')
xlabel('task\_size (ms)'), ylabel('Time (\mus) spent on overhead for each 100 \mus of useful work')