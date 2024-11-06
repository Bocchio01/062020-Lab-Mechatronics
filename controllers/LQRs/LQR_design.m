% Linear Quadratic Regulator controller design

% clc
clear variables
close all

run("maglev_init.m")
run("initial_conditions_init.m")

%% Linearized state space representation

% [x_eq, u_eq] = operating_point(z0);
% [A, B, C, D] = state_space_linearized(x_eq, u_eq);

[x_eq, u_eq] = literature_operating_point(z0);
[A, B, C, D] = literature_state_space_linearized(x_eq, u_eq);

%% LQR controller design

% Penalization matrix for the states
% x = [position, velocity, current1, current2]';
Q = diag([30 1e-3 1e+2 1e+2]);

% Penalization matrix for the inputs
% u = [voltage1, voltage2]';
R = diag(5.5);

[LQR, ~, poles] = lqr(A, B, Q, R);
% [LQR, ~, poles] = lqr(A1, B1, Q, R);

% [LQRd, ~, poles] = lqrd(A, B, Q, R, 0.003);

save("controllers\LQRs\LQR", "LQR");


%% Closed loop system

% sys = ss((A - B*LQR), B, C, D);
% [y, t, x] = initial(sys, [z0, v0, I1min, I2min]);
% 
% step(-sys)
% 
% figure
% plot(t, y);