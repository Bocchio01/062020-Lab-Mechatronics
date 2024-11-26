% clc
% clear variables
close all

run("initial_conditions.m")

% Ts = 0.005;

%% Operating point and system matrices

% Nominal condition (z0)
[x_eq, u_eq, A, B, C, D] = controllers_design_init(z0);
G = tf(ss(A, B, C, D));

% Gain scheduling conditions (z \in [0, 0.020])
z_stars = linspace(0, 0.020, 10);
G_gain_scheduling = tf(zeros(1, 1, length(z_stars)));

for z_star_idx = 1:length(z_stars)
    [x_eq_star, u_eq_star, A_star, B_star, C_star, D_star] = controllers_design_init(z_stars(z_star_idx));
    G_gain_scheduling(:, :, z_star_idx) = tf(ss(A_star, B_star, C_star, D_star));
end


%% PIDs

% PID classical
K_PID_classical = pidtune(G, 'pid', 385); % w_c \in [20 40]
% PID = pid(-825, -3.01e+03, -56.5);
% PID = pid(-314, -1.81e+03, -13.6);
% PID = pid(-1.17e+03, -3.42e+03, -99.4); % Rosinova
% controlSystemDesigner(G);

% PID anti-windup
K_PID_anti_windup = K_PID_classical;

% PID gain scheduling
K_PID_gain_scheduling = pidtune(G_gain_scheduling, 'pid', 150);

% PID cascade
% K_PID_cascade_z = pidtune(tf(ss(A, B, C, D)), 'pid', 1/8 * (pi/1e-3));
% K_PID_cascade_I = pidtune(tf(ss(A, B, C, D)), 'pid', 1/8 * (pi/1e-3));

% asymp(K_PID_classical * G)
% bode(K_PID_gain_scheduling .* G_gain_scheduling)
% [Gm,Pm,Wcg,Wcp] = margin(K_PID_gain_scheduling .* G_gain_scheduling)


%% LQs
Q = diag([30 1e-3 1e+1]);
R = diag(5.5);
% [Q, R] = autoQR(A, B, C, 1000);

% LQR classical
K_LQR_classical = lqr(A, B, Q, R);

% LQR tracking
K_LQR_tracking = K_LQR_classical;

% LQI classical -> Works with alpha = 1
Q = diag([30 1e-3 1e+1 1e+8]);
R = diag([5.5]);
K_LQI_classical = lqi(ss(A, B, C, D), Q, R);

% LQG classical
% Q = diag([30 1e-3 1e+2 1e+8]);
% R = diag([5.5]);
% K_LQG_classical = lqg(ss(A, B, C, D), Q, R);


%% MPCs

% mpcDesigner(G);
% mpcDesigner('controllers/sessions/MPC_designer_session.mat');
% K_MPC = mpc(G, Ts);
% K_MPC = mpc1;


%% KF

Q = 3e-4;
R = diag([2.98e-05]);

[kalmf, L_KF, P_KF] = kalman(ss(A, B, C, D), Q, R);


%% Luenberger observer

% K_Luenberger_observer = ? 