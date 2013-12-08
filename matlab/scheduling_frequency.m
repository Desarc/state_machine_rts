figure('Name', 'scheduling_freq')
hold off
dt = 0.01;
x = [10, 50, 100, 500, 1000]*dt;
z = [111, 498, 983, 4838, 9657];

dt2 = 111/235;

y = [1114, 222, 111, 23, 11]*dt2;
y = y.*z./100;
y = y+z;
y = y./1000000;

semilogx(x, y)
title('Maximum scheduling frequency')
xlabel('task\_size (ms)'), ylabel('Maximum scheduling frequency')