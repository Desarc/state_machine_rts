figure('Name', 'simple_overhead_rel')
hold off
x = [10, 50, 100, 500, 1000, 5000, 10000, 50000];
y1 = [0.1389, 0.2942, 0.4232, 0.7742, 0.8778, 0.9865, 1.0022, 1.0152];
y2 = [0.1209, 0.3789, 0.5481, 0.8683, 0.9370, 1.0011, 1.0097, 1.0168];
y3 = [0.1210, 0.3814, 0.5511, 0.8694, 0.9380, 1.0013, 1.0099, 1.0168];
y4 = [0.1204, 0.3819, 0.5521, 0.8700, 0.9383, 1.0014, 1.0099, 1.0168];

semilogx(x, y1, x, y2, x, y3, x, y4)
title('Simple overhead measurements of runtime system (relative)')
legend('task\_repeats = 1', 'task\_repeats = 50', 'task\_repeats = 100', 'task\_repeats = 500', 2)
xlabel('task\_size'), ylabel('Relative amount of time spent (no stm/stm)')