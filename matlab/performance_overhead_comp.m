figure('Name', 'performance_overhead_comp')
hold off
dt = 0.01;
x = [10, 50, 100, 500, 1000, 5000, 10000, 50000]*dt;

dt2 = 0.001;
opt = []*dt2;
non_opt = []*dt2;
no_rts = []*dt2;

%task_repeats = 100


loglog(x, opt, x, non_opt, x, no_rts)
title('Compared performance measurements')
legend('Optimized RTS', 'First version of RTS', 'Without RTS')
xlabel('task\_size (ms)'), ylabel('Total time spent (ms)')
