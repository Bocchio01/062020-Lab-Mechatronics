clc
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
K_PID_classical = pidtune(G, 'pid', 1/8 * (pi/1e-3));
% PID = pid(-825, -3.01e+03, -56.5);
% PID = pid(-314, -1.81e+03, -13.6);
% PID = pid(-1.17e+03, -3.42e+03, -99.4); % Rosinova
% controlSystemDesigner(G);

% PID anti-windup
K_PID_anti_windup = K_PID_classical;

% PID gain scheduling
K_PID_gain_scheduling = pidtune(G_gain_scheduling, 'pid', 1/8 * (pi/1e-3));

% PID cascade
% K_PID_cascade_z = pidtune(tf(ss(A, B, C, D)), 'pid', 1/8 * (pi/1e-3));
% K_PID_cascade_I = pidtune(tf(ss(A, B, C, D)), 'pid', 1/8 * (pi/1e-3));

% asymp(K_PID_classical * G)
% bode(K_PID_gain_scheduling .* G_gain_scheduling)
% [Gm,Pm,Wcg,Wcp] = margin(K_PID_gain_scheduling .* G_gain_scheduling)


%% LQs
Q = diag([30 1e-3 1e+2]);
R = diag(5.5);
% [Q, R] = autoQR(A, B, C, 1000);

% LQR classical
K_LQR_classical = lqr(A, B, Q, R);

% LQR tracking
K_LQR_tracking = K_LQR_classical;

% LQI classical
Q = diag([30 1e-3 1e+2 1e+8]);
R = diag([5.5]);
K_LQI_classical = lqi(ss(A, B, C, D), Q, R);

% LQG classical
% Q = diag([30 1e-3 1e+2 1e+8]);
% R = diag([5.5]);
% K_LQG_classical = lqg(ss(A, B, C, D), Q, R);


%% MPCs

% mpcDesigner(G);
% mpcDesigner('controllers/sessions/MPC_designer_session.mat');
% mpcobj = mpc(G, Ts);


%% KF
% 
% Q = 1e-10;
% R = 1e-10;
% 
% [K_KF, L_KF, P_KF] = kalman(system, Q, R);