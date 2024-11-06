% Linear Quadratic Integral controller design

clc
clear variables
close all

run("plant\init.m")

%% Linearized state space representation

% Load z0 and v0
run("initial_conditions.m")

[x_eq, u_eq] = literature_operating_point(z0);
[A, B, C, D] = literature_state_space_linearized(x_eq, u_eq);


%% LQR controller design

% Discrete time (dlqr != dlqr -> ?)
ssd = c2d(ss(A, B, C, D), 0.005, 'tustin');

Q_integrator = diag([30 1e-3 1e+2 1e+2 1.5e+3]);
R_integrator = diag(5.5);
dLQR_integrator = lqi(ssd.A, ssd.B, Q_integrator, R_integrator, 0);
