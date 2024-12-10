clc
clear variables
close all

run("initial_conditions.m")

%% Open loop transfer function L

[x_eq, u_eq, A, B, C, D] = controllers_design_init(z0);
G = tf(ss(A, B, C, D));
L = series(1, G);


%% Stability analysis

% Eigenvalue of A
assert(any(real(eig(A)) >= 0), 'The system is unstable.');

% Controllability
KR = ctrb(A, B);
assert(rank(KR) == size(A, 1), 'The system is not controllable.')

% Observability
KO = obsv(A, C);
assert(rank(KO) == size(A, 1), 'The system is not observable.')

% Bandwidth for G (?)
disp(['System Bandwidth: ' num2str(bandwidth(L)) ' rad/s']);


%% Plots

figure_no_controller = plots_for_stability(1, G, 'No controller');