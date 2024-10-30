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

nexttile
hold on
grid on

L0 = 1.106699e-02;
az = 2.451996e+02;
Lz = 4.024294e-02;
aI = 9.770851e-02;
LI = 3.750493e-02;

R0 = 4.184700e+00;
aIR = 1.872863e+00;
RI = 1.762355e+00;

I = 0.8552;
I = @(x) exp(500*x) - 0.5;
I = @(x) 0.8552;

L  = @(x, I) L0 + Lz * exp(-az * x) + LI * exp(-aI * I);
R = @(I) R0 + RI * exp(-aIR * I);
fi = @(x) fiP1 / fiP2 * exp(-x / fiP2);


fplot(@(x) L(x, I(x)) ./ R(I(x)), [0 2e-2]);
fplot(@(x) fi(x), [0 2e-2]);

legend('Theoretical', 'Approximated')