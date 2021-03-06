figure('Name', 'dynamic_memory_use_cmp')
hold off

avg_non_opt = [57.5245, 58.6919, 56.6907, 55.6758, 54.6589];
avg_opt = [55.8179, 55.6170, 55.1684, 53.9621, 52.7429];
avg_no_stm = [16.9790, 15.9857, 14.9414, 14.9372, 14.3794];
max_non_opt = [64.0908, 66.2158, 63.1025, 61.1934, 60.2510];
max_opt = [62.6152, 64.2441, 60.6348, 59.8027, 58.4863];
max_no_stm = [19.0996, 18.0439, 16.7432, 16.3145, 16.1025];
max_avail = [96, 96, 96, 96, 96];

x = [200, 300, 400, 500, 600];


plot(x, max_avail, x, max_non_opt, x, max_opt, x, max_no_stm, x, avg_non_opt, x, avg_opt, x, avg_no_stm);
title('Dynamic memory use')
legend('Max available', 'Max (non-optimalized)', 'Max (optimalized)', 'Max (no STM/RTS)', 'Average (non-optimalized)', 'Average (optimalized)', 'Average (no STM/RTS)', 'Location', 'NorthEastOutside')
xlabel('GC step multiplier value'), ylabel('Memory use (KB)')
axis([200, 600, 10, 100]);