% clc
% clear variables
close all

run("initial_conditions.m")

%% Operating point and system matrices

% Nominal condition (z0)
[x_eq, u_eq, A, B, ~, ~] = controllers_design_init(z0);

switch 'z'
    case 'z'
        C = [1 0 0];
        D = 0;
        Q_KF = 0;
        R_KF = 2.986954e-05;
    case 'I1'
        C = [0 0 1];
        D = 0;
        Q_KF = 0;
        R_KF = 4.021979e-05;
end


%% LO

L_LO = place(A', C', [-48.00  -48.12  -48.24])';


%% KF

G = zeros(size(B, 1), 1);
H = zeros(size(D, 1), 1);

[kalmf, L_KF, P_KF] = kalman(ss(A, [B G], C, [D H]), Q_KF, R_KF);