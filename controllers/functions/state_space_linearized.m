function [A, B, C, D] = state_space_linearized(x, u)

% Load system parameters
run("maglev_init.m");
[I1, I2, dI1du, dI2du, L1, L2, dL1dx, dL2dx, dL1ddx, dL2ddx] = components_equations();

% A coefficients
a11 = 0;
a12 = 1;
a13 = 0;
a14 = 0;

a21 = 1 / M * (1/2 * dL1ddx(x(1)) * x(3)^2 + 1/2 * dL2ddx(x(1)) * x(4)^2);
a22 = 0;
a23 = 1/M * dL1dx(x(1)) * x(3);
a24 = 1/M * dL2dx(x(1)) * x(4);

a31 = -1 / L1(x(1))^2 * dL1dx(x(1)) * (-R10 * x(3) + U_to_V(u(1)));
a32 = 0;
a33 = 1 / L1(x(1)) * (-R10);
a34 = 0;

a41 = -1 / L2(x(1))^2 * dL2dx(x(1)) * (-R20 * x(4) + U_to_V(u(2)));
a42 = 0;
a43 = 0;
a44 = 1 / L2(x(1)) * (-R20);

% B coefficients
b1 = 0;
b2 = 0;
b3 = 1 / L1(x(1)) * 11.65800;
b4 = 1 / L2(x(1)) * 11.65800;

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