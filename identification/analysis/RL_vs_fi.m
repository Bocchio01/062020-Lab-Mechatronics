clc
clear variables
close all

%% Load parameters

load("parameters_lagrangian.mat");
load("parameters_literature.mat");


%% Current model dynamics definitions

z = linspace(0, 2e-2, 100);

I = @(z) -2.7 * (z/2e-2).^2 + I1min + 2.7;
L_identified = @(z, I) L10 + L1z * exp(-a1z * z) + L1I * atan(a1I * I - b1I);
L_fitting = @(z) 3.75*L1z * exp(-1.2*a1z * z);
fi = @(z) fiP1 / fiP2 * exp(-z / fiP2);


%% Plots
nexttile
hold on
grid on

% plot(z * 1e3, L(z, I(z)) / R10);
plot(z * 1e3, L_identified(z, 1) / R10);
plot(z * 1e3, L_fitting(z) / R10);
plot(z * 1e3, fi(z));

title('Tau')
xlabel('z [mm]')
ylabel('\tau [1/s]')

legend('Identified', 'Fitting', 'fi')