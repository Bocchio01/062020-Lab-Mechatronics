% clc
% clear variables
% close all

run("initial_conditions.m")

%% Operating point and system matrices

% Nominal condition (z0)
[x_eq, u_eq, A, B, ~, ~] = controllers_design_init(z0);
C = [1 0 0; 0 0 1];
D = zeros(2, 1);


%% LO

L_LO = place(A', C', [-500  -400  -400])';
% eig(A - L_LO * C)


%% KF

% Larger q -> I trust the measurements more
Q_KF = diag([10 10]); %[1 10] still ok, but v drift to negative values
R_KF = diag([7.254756e-10 4.207942e-05]);
N_KF = 0;

sysKF = ss(A, [B [0 0; 1 0; 0 1]], C, [D zeros(2, 2)]);
sysKF.InputName = {'U', 'w1', 'w3'};
sysKF.OutputName = {'z', 'I'};
    
[kalmf, L_KF, P_KF] = kalman(sysKF, Q_KF, R_KF);
% eig(A - L_KF * C)


%% EKF
% Same parameters as for KF
