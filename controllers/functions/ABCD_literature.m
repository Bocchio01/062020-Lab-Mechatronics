function [A, B, C, D] = ABCD_literature(x, u)

% Load system parameters
load("parameters_literature.mat"); %#ok<LOAD>

fi = @(x) fiP1 / fiP2 * exp(-x / fiP2);

% A coefficients
a11 = 0;
a12 = 1;
a13 = 0;
a14 = 0;

a21 = 1/m * (FemP1/FemP2^2 * exp(-x(1) / FemP2) * x(3)^2 + FemP1/FemP2^2 * exp(-(H - 2*r - x(1)) / FemP2) * x(4)^2);
a22 = 0;
a23 = -2*x(3)/m * FemP1/FemP2 * exp(-x(1) / FemP2);
a24 = 2*x(4)/m * FemP1/FemP2 * exp(-(H - 2*r - x(1)) / FemP2);

a31 = -(ki*u(1) + ci - x(3)) * (x(1) / fiP2) * 1 / fi(x(1));
a32 = 0;
a33 = -1 / fi(x(1));
a34 = 0;

a41 = -(ki*u(2) + ci - x(4)) * (x(1) / fiP2) * 1 / fi(H - 2*r - x(1));
a42 = 0;
a43 = 0;
a44 = -1 / fi(H - 2*r - x(1));

% B coefficients
b11 = 0;
b12 = 0;
b21 = 0;
b22 = 0;
b31 = ki / fi(x(1));
b32 = 0;
b41 = 0;
b42 = ki / fi(H - 2*r - x(1));

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