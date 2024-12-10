% Parameters for the MagLev from literature

clc
clear variables
close all

%% Common parameters

run("parameters_common.m")


%% Current model (data from INTECO manual)
ki   = 2.5165; %[A]
ci   = 0.0243; %[A]
fiP1 = 1.4142 * 1e-4; %[m/s]
fiP2 = 4.5626 * 1e-3; %[m]


%% Inductances
% L(z) = FemP1/FemP2 * exp(-z/FemP2)

FemP1 = 1.7521e-02; %[H]
FemP2 = 5.8231e-03; %[m]


%% Updating the .mat file

save('identification\parameters\parameters_literature.mat')