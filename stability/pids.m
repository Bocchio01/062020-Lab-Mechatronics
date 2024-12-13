% clc
% clear variables
% close all

run("initial_conditions.m")

%% Open loop transfer function L

[x_eq, u_eq, A, B, C, D] = controllers_design_init(z0);
G = tf(ss(A, B, C, D));
Gd = tf(c2d(ss(A, B, C, D), 0.001, 'tustin'));

%% Loops over PIDs

Kp = linspace(-150, -50, 20);
% Ki = linspace(-450, -50, 10);
Ki = 300;ii = 1;
Kd = linspace(-10, -2, 20);

Stable = NaN(numel(Kp), numel(Ki), numel(Kd));
GM = NaN(numel(Kp), numel(Ki), numel(Kd));
PM = NaN(numel(Kp), numel(Ki), numel(Kd));

warning('off', 'Control:analysis:MarginUnstable')
for pp = 1:numel(Kp)
    % for ii = 1:numel(Ki)
        for dd = 1:numel(Kd)
            L = series(pid(Kp(pp), Ki, Kd(dd), 0.001), G);
            [gain_margin, phase_margin, ~, ~] = margin(L);
            GM(pp, ii, dd) = gain_margin;
            PM(pp, ii, dd) = phase_margin;
            Stable(pp, ii, dd) = isstable(feedback(L, 1)) & phase_margin > 5 & db(gain_margin) < 5;
        end
    % end
end

stableIdx = Stable == 1;
unstableIdx = Stable == 0;


%% Plots

figure
hold on
grid on
[X, Y, Z] = meshgrid(Kp, Ki, Kd);

scatter3(X(stableIdx), Y(stableIdx), Z(stableIdx), 'red', 'filled')
scatter3(X(unstableIdx), Y(unstableIdx), Z(unstableIdx), 'blue', 'filled')
scatter3(-100, -120, -15, 75, 'black', 'filled')

view(-60, 15)
title('PIDs stabilities')
xlabel('Kp')
ylabel('Ki')
zlabel('Kd')
legend('Stable', 'Unstable', 'Designed')


%%

bestPIDidx = find(PM == max(PM, [], 'all'), 1);
[pp, ii, dd] = ind2sub(size(PM), bestPIDidx);

bestPIDidx = find(GM == min(GM(), [], 'all'), 1);
[pp, ii, dd] = ind2sub(size(GM), bestPIDidx);

bestPID = pid(Kp(pp), Ki(ii), Kd(dd))
figure_PID_classical = plots_for_stability(bestPID, G, 'PID classical');