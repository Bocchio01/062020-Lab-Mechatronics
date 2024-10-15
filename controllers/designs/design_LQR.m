clc
clear variables
close all

run("plant\init.m")

%% Linearized state space representation

% Load z0 and v0
run("initial_conditions.m")

[x_eq, u_eq] = compute_operating_point(z0);
[A, B, C, D] = state_space_linearized(x_eq, u_eq);


%% LQR controller design

% Penalization matrix for the states
% x = [position, velocity, current1, current2]';
Q = zeros(size(A, 1)) + diag([30 1e-3 1e+2 1e+2]);

% Penalization matrix for the inputs
% u = [voltage1, voltage2]';
R = zeros(size(D, 1)) + diag(5.5);

[K, ~, poles] = lqr(A, B, Q, R);


%% Closed loop system

sys = ss((A - B*K), B, C, D);
[y, t, x] = initial(sys, [z0, v0, ci, ci]);

figure
plot(t, y);