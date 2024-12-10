clc
clear variables
close all

run("initial_conditions.m")

%% Open loop transfer function L

[x_eq, u_eq, A, B, C, D] = controllers_design_init(z0);
G = tf(ss(A, B, C, D));


%% Loops over PIDs

Kp = linspace(-100, -50, 20);
Ki = linspace(-300, -150, 8);
Kd = linspace(-5, -2, 10);

Stable = NaN(numel(Kp), numel(Ki), numel(Kd));
PM = NaN(numel(Kp), numel(Ki), numel(Kd));

warning('off', 'Control:analysis:MarginUnstable')
for pp = 1:numel(Kp)
    for ii = 1:numel(Ki)
        for dd = 1:numel(Kd)
            L = series(pid(Kp(pp), Ki(ii), Kd(dd)), G);
            [~, phase_margin, ~, ~] = margin(L);
            PM(pp, ii, dd) = phase_margin;
            Stable(pp, ii, dd) = isstable(feedback(L, 1)) & phase_margin > 10;
        end
    end
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
scatter3(-87.5, -87.5 / Ti, -87.5 * Td, 75, 'black', 'filled')

view(-60, 15)
title('PIDs stabilities')
xlabel('Kp')
ylabel('Ki')
zlabel('Kd')
legend('Stable', 'Unstable', 'Designed')