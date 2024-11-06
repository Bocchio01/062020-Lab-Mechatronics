% Modelling and control of a Magnetic Levitation System
%
% This project explores traditional and modern control theory techniques 
% to stabilize the position of a ferromagnetic ball suspended in a magnetic 
% field produced by two inductors.
% A "Model-based design" (MBD) approach has been adopted.
%
% Author =  Tommaso Bocchietti, Daniele Cianca, Sara Orazzo
% Date =  00/00/2024
%
% Requires = 
%   - Simulink
%   - Coder Toolbox
%   - INTECO MSL2EM Toolbox (licensed from the producer)
% 
% Reference course =  062020 (Politecnico di Milano A.Y. 2024/2025)

clc
clear variables
close all

%% Simulation parameters

run("initial_conditions_init.m")
run("maglev_init.m")

%% Simulation launcher

% sim("System.slx")

%%

% nexttile
% hold on
% grid on
% 
% run("maglev_init.m")
% load("inductance_analysis.mat")
% 
% I = @(x) 1;
% % I = @(x) exp(10000 * x);
% 
% % dLdI = @(x, I) -aI * LI * exp(-aI * I) .*  exp(-az * 1000 * x);
% % L = @(x, I) L0 + Lz * exp(-az * x) + LI * exp(-aI * I) .*  exp(-az * 1000 * x) + dLdI(x, I);
% L = @(x, I) L0 + Lz * exp(-az * x) + LI * tanh(-aI * I);
% 
% 
% % L  = @(x, I) 0 + 2.5*L1z * exp(-1.2*a * x);
% 
% fplot(@(x) L(x, I(x)), [0 2e-2]);
% fplot(@(x) R10 * fiP1 / fiP2 * exp(-x / fiP2), [0 2e-2]);
% 
% legend('Theoretical', 'Approximated')