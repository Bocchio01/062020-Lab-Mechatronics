% Parameters for the MagLev

% Physical constants
g   = 9.81; %[m/s^2]
rho = 1.21; %[kg/m^3]
Cd  = 0.45; %[Ns/m]

% Components
run("components\inductances\init.m")
run("components\resistances\init.m")

% Structure
H = (75 + 61.25) * 1e-3; %[m]

% Ball/object
m = 57.57 * 1e-3;   %[kg]
r = 61.25/2 * 1e-3; %[m]
A = pi * r^2;       %[m^2]

% Approximated current model
ki   = 2.5165;
ci   = 0.0243;
fiP1 = 1.4142 * 1e-4;
fiP2 = 4.5626 * 1e-3;