% Kalman Filter design

% clc
clear variables
close all

run("maglev_init.m")
run("initial_conditions_init.m")

%% Linearized state space representation

[x_eq, u_eq] = literature_operating_point(z0);
[A, B, C, D] = literature_state_space_linearized(x_eq, u_eq);

%% Kalman filter design

% Discrete time
ssd = c2d(ss(A, B, C, D), 0.005, 'tustin');

Q = 1e-10;
R = 1e-10;

[K_KF, L_KF, P_KF] = kalman(ssd, Q, R);