function [A, B, C, D] = ABCD_lagrangian(x, u)

% Load system parameters
load("parameters_lagrangian.mat"); %#ok<LOAD>

L1 = @(x, I) 1/1 * (L10 + L1z * exp(-a1z*x) + L1I * atan(a1I * I - b1I));
L2 = @(x, I) 1/1 * (L20 + L2z * exp(-a2z*(H - 2*r - x)) + L2I * atan(a2I * I - b2I));
dL1dx = @(x) -a1z*L1z * exp(-a1z*x);
dL2dx = @(x) +a2z*L2z * exp(-a2z*(H - 2*r - x));
dL1ddx = @(x) +a1z^2*L1z * exp(-a1z*x);
dL2ddx = @(x) +a2z^2*L2z * exp(-a2z*(H - 2*r - x));
% dL1dI = @(I) a1I * I / (1 + (a1I * I - b1I)^2);
% dL2dI = @(I) a2I * I / (1 + (a2I * I - b2I)^2);
% dL1ddI = @(I) -a1I * I / ((1 + (a1I * I - b1I)^2)^2 * 2*(a1I * I - b1I) * a1I);
% dL2ddI = @(I) -a2I * I / ((1 + (a2I * I - b2I)^2)^2 * 2*(a2I * I - b2I) * a2I);


% A coefficients
a11 = 0;
a12 = 1;
a13 = 0;
a14 = 0;

a21 = 1 / m * (1/2 * dL1ddx(x(1)) * x(3)^2 + 1/2 * dL2ddx(x(1)) * x(4)^2);
a22 = 0;
a23 = 1/m * dL1dx(x(1)) * x(3);
a24 = 1/m * dL2dx(x(1)) * x(4);

a31 = -1 / L1(x(1), x(3))^2 * dL1dx(x(1)) * (-R10 * x(3) + U_to_V(u(1)));
a32 = 0;
a33 = 1 / L1(x(1), x(3)) * (-R10);
a34 = 0;

a41 = -1 / L2(x(1), x(4))^2 * dL2dx(x(1)) * (-R20 * x(4) + U_to_V(u(2)));
a42 = 0;
a43 = 0;
a44 = 1 / L2(x(1), x(4)) * (-R20);

% B coefficients
b11 = 0;
b12 = 0;
b21 = 0;
b22 = 0;
b31 = 1 / L1(x(1), x(3)) * k1;
b32 = 0;
b41 = 0;
b42 = 1 / L2(x(1), x(4)) * k2;

% C coefficients
c1 = 1;
c2 = 0;
c3 = 0;
c4 = 0;

% D coefficients
d1 = 0;
d2 = 0;


% State matrices
A = [
    a11 a12 a13 a14;
    a21 a22 a23 a24;
    a31 a32 a33 a34;
    a41 a42 a43 a44
    ];

B = [
    b11 b12;
    b21 b22;
    b31 b32;
    b41 b42
    ];

C = [c1 c2 c3 c4];

D = [d1 d2];

end