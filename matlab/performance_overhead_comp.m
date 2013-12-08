figure('Name', 'performance_overhead_comp')
hold off
dt = 0.01;
x = [10, 50, 100, 500, 1000, 5000, 10000, 50000]*dt;

dt2 = 0.001;
opt = [67246, 105689, 153840, 539316, 1021318, 4878899, 9700721, 48278627]*dt2;
non_opt = [100335, 138778, 186870, 572331, 1054338, 4911916, 9733705, 48311422]*dt2;
no_rts = [11174, 49615, 97763, 483242, 965238, 4822804, 9644615, 48222338]*dt2;

%task_repeats = 100


loglog(x, opt, x, non_opt, x, no_rts)
title('Compared performance measurements')
legend('Optimized RTS', 'First version of RTS', 'Without RTS')
xlabel('task\_size (ms)'), ylabel('Total time spent (ms)')
