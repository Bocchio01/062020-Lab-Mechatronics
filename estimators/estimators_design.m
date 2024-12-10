% clc
% clear variables
close all

run("initial_conditions.m")

%% Operating point and system matrices

% Nominal condition (z0)
[x_eq, u_eq, A, B, ~, ~] = controllers_design_init(z0);

C = eye(3);
D = 0;

Q_KF = diag([1e-7 1e-20 1e-7]);
R_KF = diag([7.254756e-10 1.881713e-03 4.207942e-05]);


%% LO

L_LO = place(A', C', [-48.00  -48.12  -48.24])';

eig(A - L_LO * C)


%% KF
    
% [kalmf, L_KF, P_KF] = kalman(ss(A, B, C, D), Q_KF, R_KF);
[~, ~, L_KF] = care(A', C', Q_KF, R_KF);
L_KF = L_KF';

eig(A - L_KF * C)