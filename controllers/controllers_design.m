% clc
% clear variables
% close all

plot_analysis = 0;

run("initial_conditions.m")

%% Operating point and system matrices

% Nominal condition (z0)
[x_eq, u_eq, A, B, C, D] = controllers_design_init(z0);
G = tf(ss(A, B, C, D));

% Gain scheduling conditions (z \in [0.050, 0.020])
z_stars = linspace(0.005, 0.020, 5);
G_gain_scheduling = tf(zeros(1, 1, length(z_stars)));

for z_star_idx = 1:length(z_stars)
    [x_eq_star, u_eq_star, A_star, B_star, C_star, D_star] = controllers_design_init(z_stars(z_star_idx));
    G_gain_scheduling(:, :, z_star_idx) = tf(ss(A_star, B_star, C_star, D_star));
end

% Cascaded controller (z0)
G_cascade = tf(ss(A, B, [1 0 0; 0 0 1], zeros(2, 1)));
G_cascade_z = G_cascade(1);
G_cascade_I = G_cascade(2);


%% PIDs

kp0 = -100;

kp = kp0;
Ti0 = 100 / 120; %1 / 3;
Td0 = 13 / 100; %1 / 22;

% PID classical
K_PID_classical = pid(kp, kp / Ti0, kp * Td0); % Should be good at 0.010

% K_PID_classical = pid(-200, -240, -16); % Should be good at 0.020
% K_PID_classical = pid(-100, -120, -8); % Good at 0.001
% K_PID_classical = pid(-50, -60, -3); % Good at 0.005

% PID anti-windup
K_PID_anti_windup = K_PID_classical;


% PID gain scheduling
kp = zeros(length(z_stars), 1);
Td = zeros(length(z_stars), 1);
K_PID_gain_scheduling = pid;
for z_star_idx = 1:length(z_stars)
    kp(z_star_idx) = interp1([0.000 0.005 0.010 0.020], kp0 * [0.45 0.68 1.00 2.28], z_stars(z_star_idx), 'spline', 'extrap');
    % Td(z_star_idx) = interp1([0.008 0.010], Td0 * [1.8750 1], z_stars(z_star_idx), 'spline', 'extrap');
    K_PID_gain_scheduling(:, :, z_star_idx) = pid(kp(z_star_idx), kp(z_star_idx) / Ti0, kp(z_star_idx) * Td0);
end

% figure
% hold on
% grid on
% plot(z_stars, Td * 100, '-k')
% plot([0.008 0.010], 100 * Td0 * [1.8750 1], 'o')

% PID cascade
% kp = kp0;
% K_PID_cascade_I = pidtune(G_cascade_I, 'pid');
% K_PID_cascade_z = pidtune(G_cascade_z, 'pid');

if plot_analysis
    figure_PID_classical = plots_for_stability(K_PID_classical, G, 'PID classical');
    % figure_PID_cascade_I = plots_for_stability(K_PID_cascade_I, G_cascade_I, 'PID cascade (I)');
    % figure_PID_cascade_z = plots_for_stability(K_PID_cascade_z, G_cascade_z, 'PID cascade (z)');
    figure_PID_gain_scheduling = plots_for_stability(K_PID_gain_scheduling, G_gain_scheduling, 'PID gain-scheduling');
end


%% LQs
% Bryson’s rule
Q = diag([1 0 1] ./ ([0.02 1 2.5].^2));
R = diag(0.5 ./ 1^2);
% Q = diag([30 1e-3 1e1]);
% R = diag(5.5);

% LQR classical
[K_LQR_classical, PP, poles] = lqr(A, B, Q, R);

% LQR tracking
K_LQR_tracking = K_LQR_classical;

% LQI classical
Q = blkdiag(Q, 1e+5);
[K_LQI_classical, S, e] = lqi(ss(A, B, C, D), Q, R);


if plot_analysis

    T = ss(A - B * K_LQR_classical, B, C, D);
    figure
    step(-T)
    % figure_LQR = plots_for_stability(1, T / (1 - T), 'LQR');

    % G_LQR = ss(A - B * K_LQR_classical, B, C, D);
    % op = findop(G_LQR, y = 1);
    % sys_tf = tf(op.u*G_LQR);
    % step(G_LQR)
    % grid on   

    % step(feedback(G * K_LQR_tracking', 1))

    % figure
    % step(feedback(G_cl, 1));
    % 

    % Closed-loop system matrices
    A_cl = [
        A - B * K_LQI_classical(1:3), B * K_LQI_classical(4); ...
        -C 0
        ];
    B_cl = [zeros(1, 3) 1]';
    C_cl = [C 0];
    D_cl = 0;

    eig(A_cl)

    % Create closed-loop system
    G_cl = ss(A_cl, B_cl, C_cl, D_cl);
    % figure_LQI = plots_for_stability(1, G_cl, 'LQI');

end


%% MPCs

% mpcDesigner(K_MPC)

K_MPC = mpc(G, 0.001);
K_MPC.PredictionHorizon = 1000;
K_MPC.ControlHorizon = 1;

% Nominal values considered for linear model
K_MPC.Model.Nominal.U = u_eq(1);
K_MPC.Model.Nominal.Y = z0;

% Constraints on u and z
K_MPC.MV(1).Min = 0;
K_MPC.MV(1).Max = 1;
K_MPC.OV(1).Min = 0;
K_MPC.OV(1).Max = 0.020;

% Tuning weight
beta = 2.7183; % Higher beta prioritizes output tracking (large OV weight) over control effort (smaller MV weight).
alpha = 3.1623; % If noisy sensors introduce significant noise, reducing alpha helps improve robustness to noise.

K_MPC.Weights.MV = 1*beta;
K_MPC.Weights.MVRate = 55/beta;
K_MPC.Weights.OV = 1000*beta;
K_MPC.Weights.ECR = 100000;

setoutdist(K_MPC, 'model', getoutdist(K_MPC)*alpha);
K_MPC.Model.Noise = K_MPC.Model.Noise/alpha;

if plot_analysis

    % Simulation options
    options = mpcsimopt();
    options.MVSignal = K_MPC_MVSignal;
    options.RefLookAhead = 'off';
    options.MDLookAhead = 'off';
    options.Constraints = 'on';
    options.OpenLoop = 'off';

    sim(K_MPC, 10001, K_MPC_RefSignal, K_MPC_MDSignal, options);

end

