% Model Predictive Controller design

clc
clear variables
close all

run("maglev_init.m")
run("initial_conditions_init.m")

%% Linearized state space representation

[x_eq, u_eq] = literature_operating_point(z0);
[A, B, C, D] = literature_state_space_linearized(x_eq, u_eq);

system = ss(A,B,C,D);


% Open the design tool
mpcDesigner