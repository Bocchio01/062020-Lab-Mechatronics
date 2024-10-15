function [A, B, C, D] = state_space_linearized(x, u)

% Load system parameters
run("plant\init.m");

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