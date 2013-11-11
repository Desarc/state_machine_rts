figure('Name', 'simple_overhead_abs')
hold off
x = [10, 50, 100, 500, 1000, 5000, 10000, 50000];
y1 = [1538, 1528, 1521, 1450, 1363, 664, -215, -7239];
y2 = [823, 816, 807, 733, 649, -53, -931, -7955];
y3 = [812, 805, 796, 726, 638, -64, -942, -7965];
y4 = [808, 801, 792, 722, 634, -68, -946, -7969];

semilogx(x, y1, x, y2, x, y3, x, y4)
title('Simple overhead measurements of runtime system')
legend('task\_repeats = 1', 'task\_repeats = 50', 'task\_repeats = 100', 'task\_repeats = 500', 3)
xlabel('task\_size'), ylabel('Absolute time difference per repeat in \mus (stm - no stm)')