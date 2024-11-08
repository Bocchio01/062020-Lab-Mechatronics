function [I1, I2, dI1du, dI2du, L1, L2, dL1dx, dL2dx, dL1ddx, dL2ddx] = components_equations()

% Load system parameters
run("maglev_init.m");

I1 = @(u) ...
    + I1min .* (u < U1min) + ...
    + (m * u + q) .* (u >= U1min);
I2 = @(u) ...
    + I2min .* (u < U2min) + ...
    + (m * u + q) .* (u >= U2min);

dI1du = @(u) ...
    + 0 .* (u < U1min) + ...
    + m .* (u >= U1min);
dI2du = @(u) ...
    + 0 .* (u < U2min) + ...
    + m .* (u >= U2min);

dI1du = @(u) m;
dI2du = @(u) m;

L1 = @(x) L10 + L1z * exp(-a1z*x);
L2 = @(x) L20 + L2z * exp(-a2z*(H - 2*r - x));
dL1dx = @(x) -a1z*L1z * exp(-a1z*x);
dL2dx = @(x) +a2z*L2z * exp(-a2z*(H - 2*r - x));
dL1ddx = @(x) +a1z^2*L1z * exp(-a1z*x);
dL2ddx = @(x) +a2z^2*L2z * exp(-a2z*(H - 2*r - x));

end