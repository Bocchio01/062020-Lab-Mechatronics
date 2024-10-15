clc
clear variables
close all

run("plant\init.m")

%% Linearized state space representation

% Load z0 and v0
run("initial_conditions.m")

[x_eq, u_eq] = compute_operating_point(z0);
[A, B, C, D] = state_space_linearized(x_eq, u_eq);


%% Transfer function of the plant (linearized)

[G_numerator, G_denominator] = ss2tf(A, B, C, D);
G = tf(G_numerator, G_denominator);

% controlSystemDesigner(G);

%% PID controller design

switch 2
    case 1
        % Reference cross over frequency (1 decade before a chosen Nyquist frequency)
        cross_over_frquency = 1/10 * (pi/1e-3);
        [R, pidtune_info] = pidtune(G, 'pid', cross_over_frquency);
    case 2
        % controlSystemDesigner result
        R = pid(-188, -728, -12.1);
    case 3
        % Rosinova parameters
        R = pid(-125, -377.830, -5.65);
end

L = R * G;

% Discrete-time
% SISOLinearizedMaglevDiscrete = c2d(ss(A, B, C, D), 0.005, 'tustin');
% F = SISOLinearizedMaglevDiscrete.A;
% G = SISOLinearizedMaglevDiscrete.B;
% H = SISOLinearizedMaglevDiscrete.C;

%% Plots

figure
hold on
grid on

asymp(L);
[Gain_margin, Phase_margin, Phase_crossover_frequency, Gain_crossover_frequency] = margin(L);
rlocus(L);
