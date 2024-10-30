% Proportional Integral Derivative controller design

clc
clear variables
close all

run("maglev_init.m")
run("initial_conditions_init.m")

%% Linearized state space representation

[x_eq, u_eq] = literature_operating_point(z0);
[A, B, C, D] = literature_state_space_linearized(x_eq, u_eq);


%% Transfer function of the plant (linearized)

[G_numerator, G_denominator] = ss2tf(A, B, C, D);
G = tf(G_numerator, G_denominator);

% controlSystemDesigner(G);


%% PID controller design

switch 2
    case 1
        % Reference cross over frequency (1 decade before a chosen Nyquist frequency)
        cross_over_frquency = 1/10 * (pi/1e-3);
        [PID, pidtune_info] = pidtune(G, 'pid', cross_over_frquency);
    case 2
        % controlSystemDesigner result
        PID = pid(-314, -1.81e+03, -13.6);
        % PID = pid(-1.17e+03, -3.42e+03, -99.4);
    case 3
        % Rosinova parameters
        PID = pid(-125, -377.830, -5.65);
end

L = PID * G;

% Discrete-time
% SISOLinearizedMaglevDiscrete = c2d(ss(A, B, C, D), 0.005, 'tustin');
% F = SISOLinearizedMaglevDiscrete.A;
% G = SISOLinearizedMaglevDiscrete.B;
% H = SISOLinearizedMaglevDiscrete.C;

save("controllers\PIDs\PID", "PID");

%% Plots

% figure
% hold on
% grid on
% 
% asymp(L);
% [Gain_margin, Phase_margin, Phase_crossover_frequency, Gain_crossover_frequency] = margin(L);
% rlocus(L);
