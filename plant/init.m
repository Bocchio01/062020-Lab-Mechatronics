% Parameters for the MagLev

% Physical constants
g   = 9.81; %[m/s^2]
rho = 1.21; %[kg/m^3]
Cd  = 0.45; %[Ns/m]

% Components
run("components\inductances\init.m")
run("components\resistances\init.m")

% Structure
H = 98.00 * 1e-3; %[m]

% Ball/object
m = 60.54 * 1e-3;   %[kg]
r = 61.25/2 * 1e-3; %[m]
A = pi * r^2;       %[m^2]

% Approximated current model
ki   = 1 / R10; %[1/ohm]
ci   = 2.383122e-02; %[A]
fiP1 = 1.4142 * 1e-4;
fiP2 = 4.5626 * 1e-3;