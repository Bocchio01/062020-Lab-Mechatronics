% Pole Placement controller design

clc
clear variables
close all

run("plant\init.m")

%% Linearized state space representation

% Load z0 and v0
run("initial_conditions.m")

[x_eq, u_eq] = compute_operating_point(z0);
[A, B, C, D] = state_space_linearized(x_eq, u_eq);