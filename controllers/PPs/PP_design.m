% Pole Placement controller design

clc
clear variables
close all

run("maglev_init.m")

%% Linearized state space representation

% Load z0 and v0
run("initial_conditions_init.m")

[x_eq, u_eq] = literature_operating_point(z0);
[A, B, C, D] = literature_state_space_linearized(x_eq, u_eq);