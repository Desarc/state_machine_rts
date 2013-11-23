figure('Name', 'performance_overhead_comp')
hold off
dt = 0.01;
x = [10, 50, 100, 500, 1000, 5000, 10000, 50000]*dt;

dt2 = 0.001;
opt = [63747, 95016, 138354, 485282, 919083, 4390906, 8730549, 43450652]*dt2;
non_opt = [95312, 124937, 168298, 515244, 949044, 4420840, 8760509, 43480396]*dt2;
no_rts = [11171, 49611, 97764, 483244, 965242, 4822820, 9644646, 48222514]*dt2;

loglog(x, opt, x, non_opt, x, no_rts)
title('Compared performance measurements')
legend('Optimized RTS', 'First version of RTS', 'Without RTS')
xlabel('task\_size (ms)'), ylabel('Total time spent (ms)')
