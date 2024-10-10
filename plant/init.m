% Parameters for the MagLev

% Physical constants
g = 9.81;
rho = 0;
Cd = 0;

% Subcomponents
run("components\inductances\init.m")
run("components\resistances\init.m")

% Structure
D = 100 * 1e-3; %[m]

% Ball/object
m = 0.06157; %[kg]
r = 61.25 * 1e-3; %[m]
A = 0; %[m^2]

% Approximated current model
ki = 2.7352;
ci = -0.1104;
fiP1 = 1.4142 * 1e-4;
fiP2 = 4.5626 *1e-3;

% Minimun voltage in coil
V0 = 0.01;
