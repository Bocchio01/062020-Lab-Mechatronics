% clc
% clear variables
% close all

plot_analysis = 1;

run("initial_conditions.m")

%% Operating point and system matrices

% Nominal condition (z0)
[x_eq, u_eq, A, B, C, D] = controllers_design_init(0.012);
G = tf(ss(A, B, C, D));

% Gain scheduling conditions (z \in [0.050, 0.020])
z_stars = linspace(0.005, 0.020, 5);
G_gain_scheduling = tf(zeros(1, 1, length(z_stars)));

for z_star_idx = 1:length(z_stars)
    [x_eq_star, u_eq_star, A_star, B_star, C_star, D_star] = controllers_design_init(z_stars(z_star_idx));
    G_gain_scheduling(:, :, z_star_idx) = tf(ss(A_star, B_star, C_star, D_star));
end


%% PIDs

kp0 = -150;

kp = kp0;
Ti0 = 1 / 3;
Td0 = 1 / 22;

% PID classical
K_PID_classical = pid(kp, kp / Ti0, kp * Td0); % Should be good at 0.010

% K_PID_classical = pid(-200, -240, -16); % Should be good at 0.020
% K_PID_classical = pid(-100, -120, -15); % Good at 0.001
% K_PID_classical = pid(-50, -60, -3); % Good at 0.005

% PID anti-windup
K_PID_anti_windup = K_PID_classical;

% PID gain scheduling
kp = zeros(length(z_stars), 1);
Tp = zeros(length(z_stars), 1);
K_PID_gain_scheduling = pid;
for z_star_idx = 1:length(z_stars)
    kp(z_star_idx) = interp1([0.000 0.005 0.010 0.020], kp0 * [0.45 0.68 1.00 2.28], z_stars(z_star_idx), 'spline', 'extrap');
    K_PID_gain_scheduling(:, :, z_star_idx) = pid(kp(z_star_idx), kp(z_star_idx) / Ti0, kp(z_star_idx) * Td0);
end


if plot_analysis

    figure_PID_classical = plots_for_stability(K_PID_classical, G, 'PID classical');
    figure_PID_gain_scheduling = plots_for_stability(K_PID_gain_scheduling, G_gain_scheduling, 'PID gain-scheduling');

    try %#ok<TRYNC>
        export_pdf_graphic(figure_PID_classical, '/controllers/PID_classical');
        export_pdf_graphic(figure_PID_gain_scheduling, '/controllers/PID_gain_scheduling');
    end

end


%% LQs

% Bryson’s rule
Q = diag([10 0 1] ./ ([0.020 1 2.5].^2));
R = diag(0.5 ./ 1^2);

% LQR classical
K_LQR_classical = lqr(A, B, Q, R);

% LQR tracking
K_LQR_tracking = K_LQR_classical;

% LQI classical
Q = blkdiag(Q, 1e+7);
K_LQI_classical = lqi(ss(A, B, C, D), Q, R);


%% MPCs

% Ts = 0.001
% Prediction = 100
% Control = 10

% mpcDesigner('controllers/sessions/MPC_designer_session.mat')