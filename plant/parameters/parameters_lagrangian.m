% Parameters for the MagLev

clc
clear variables
close all

%% Common parameters

run("parameters_common.m")


%% Drag related coefficients
rho = 1.21; %[kg/m^3]
Cd  = 0.45; %[Ns/m]


%% Current model
V1min = 4.300000e-02; %[V]
V2min = 4.300000e-02; %[V]
I1min = 2.383122e-02; %[A]
I2min = 2.591441e-02; %[A]
k1 = +1.165800e+01; %[V/MU]
k2 = +1.165800e+01; %[V/MU]
c1 = -5.608000e-01; %[V]
c2 = -5.608000e-01; %[V]


%% Inductances
% L(z, I) = L0 + Lz * exp(-az * z) + LI * atan(aI * I - bI);

% Static
L10 = 6.122809e-02; %[H]
L20 = 6.122809e-02; %[H]

% Position z
a1z = 1.837302e+02; %[1/m]
a2z = 1.837302e+02; %[1/m]
L1z = 3.438228e-02; %[H]
L2z = 3.438228e-02; %[H]

% Current I
a1I = 4.759750e+00; %[]
a2I = 4.759750e+00; %[]
b1I = 6.704755e-01; %[A]
b2I = 6.704755e-01; %[A]
L1I = 3.831209e-02; %[H]
L2I = 3.831209e-02; %[H]


%% Resistances
% R() = R0

% Static
R10 = 4.17; %[ohm]
R20 = 4.20; %[ohm]


%% Updating the .mat file

save('plant\parameters\parameters_lagrangian.mat')