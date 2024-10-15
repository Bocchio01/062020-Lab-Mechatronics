clc
clear variables
close all

run("plant\init.m");

%% Linearized model around a chosen operating point

x_eq = zeros(4, 1);
u_eq = zeros(2, 1);

x_eq(1) = z0;
x_eq(2) = 0;
x_eq(4) = 0.39;
x_eq(3) = sqrt( (2*m*g + x_eq(4)^2 * a2*L2z * exp(-a2 * (H - 2*r - x_eq(1)))) / (a1*L1z * exp(-a1*x_eq(1))) );

u_eq(1) = (x_eq(3) - ci) / ki;
u_eq(2) = (x_eq(4) - ci) / ki;

[A, B, C, D] = state_space(x_eq, u_eq);


%% Transfer function of the plant (linearized)

[G_numerator, G_denominator] = ss2tf(A, B, C, D);
G = tf(G_numerator, G_denominator);

% controlSystemDesigner(G);

%% PID controller design

% Reference cross over frequency (1 decade before a chosen Nyquist frequency)
cross_over_frquency = 1/10 * (pi/1e-3);

[R, pidtune_info] = pidtune(G, 'pid', cross_over_frquency);
R = -1*R;
% R = pid(-114, -1.16e+3, -2.78);
L = R * G;

pole(feedback(L, 1))

figure
hold on
grid on

asymp(L);
[Gain_margin, Phase_margin, Phase_crossover_frequency, Gain_crossover_frequency] = margin(L);
rlocus(-L);

% Discrete-time
% SISOLinearizedMaglevDiscrete = c2d(ss(A, B, C, D), 0.005, 'tustin');
% F = SISOLinearizedMaglevDiscrete.A;
% G = SISOLinearizedMaglevDiscrete.B;
% H = SISOLinearizedMaglevDiscrete.C;

%% Functions

function [A, B, C, D] = state_space(x, u)

% System parameters retrieved from base workspace
m = evalin('base', 'm');
H = evalin('base', 'H');
r = evalin('base', 'r');
ki = evalin('base', 'ki');
ci = evalin('base', 'ci');
a1 = evalin('base', 'a1');
a2 = evalin('base', 'a2');
L1z = evalin('base', 'L1z');
L2z = evalin('base', 'L2z');
fiP1 = evalin('base', 'fiP1');
fiP2 = evalin('base', 'fiP2');

fi = @(x) fiP1 / fiP2 * exp(-x / fiP2);

% A coefficients
a11 = 0;
a12 = 1;
a13 = 0;
a14 = 0;

a21 = x(3)^2/m * a1^2*L1z * exp(-a1 * x(1)) + x(4)^2/m * a2^2*L2z * exp(-a2 * (H - 2*r - x(1)));
a22 = 0;
a23 = -2*x(3)/m * a1*L1z * exp(-a1 * x(1));
a24 = +2*x(4)/m * a2*L2z * exp(-a2 * (H - 2*r - x(1)));

a31 = -(ki*u(1) + ci - x(3)) * (x(1) / fiP2) * 1 / fi(x(1));
a32 = 0;
a33 = -1 / fi(x(1));
a34 = 0;

a41 = -(ki*u(2) + ci - x(4)) * (x(1) / fiP2) * 1 / fi(H - 2*r - x(1));
a42 = 0;
a43 = 0;
a44 = -1 / fi(H - 2*r - x(1));

% B coefficients
b1 = 0;
b2 = 0;
b3 = ki / fi(x(1));
b4 = ki / fi(H - 2*r - x(1));

% C coefficients
c1 = 1;
c2 = 0;
c3 = 0;
c4 = 0;

% D coefficients
d = 0;


% State matrices
A = [
    a11 a12 a13 a14;
    a21 a22 a23 a24;
    a31 a32 a33 a34;
    a41 a42 a43 a44
    ];

B = [
    b1;
    b2;
    b3;
    b4
    ];

C = [c1 c2 c3 c4];

D = d;

end