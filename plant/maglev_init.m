% Parameters for the MagLev

% Physical constants
g   = 9.81; %[m/s^2]
rho = 1.21; %[kg/m^3]
Cd  = 0.45; %[Ns/m]

% Components
run("inductances_init.m")
run("resistances_init.m")

% Structure
H = 98.00 * 1e-3; %[m]

% Ball/object
M = 60.54 * 1e-3;   %[kg]
r = 61.25/2 * 1e-3; %[m]
A = pi * r^2;       %[m^2]

% Theoretical current model
I1min = 2.383122 * 1e-2; %[A]
I2min = 2.591441 * 1e-2; %[A]
U1min = 0.00498; %[MU]
U2min = 0.00498; %[MU]
m = 2.5165; %[A/MU]
q = 0.0243; %[A]


% Approximated current model (data from INTECO manual)
ki   = 2.5165; %[1/ohm]
ci   = 0.0243; %[A]
fiP1 = 1.4142 * 1e-4;
fiP2 = 4.5626 * 1e-3;