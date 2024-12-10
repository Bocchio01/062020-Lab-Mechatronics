function [x_eq, u_eq] = operating_point_lagrangian(z_star, I2_star)

% Load system parameters
load("parameters_lagrangian.mat"); %#ok<LOAD>

dL1dx = @(x) -a1z*L1z * exp(-a1z*x);
dL2dx = @(x) +a2z*L2z * exp(-a2z*(H - 2*r - x));

if (nargin == 1)
    % Chosen in order to ignore the effect of the lower electromagnet
    I2_star = V2min / R20;
end

x_eq = zeros(4, 1);
u_eq = zeros(2, 1);

x_eq(1) = z_star;
x_eq(2) = 0;
x_eq(4) = I2_star;
x_eq(3) = sqrt( -(2*m*g + dL2dx(x_eq(1)) * x_eq(4)^2) / dL1dx(x_eq(1)) );

u_eq(1) = max([0, R10 * (x_eq(3) - I1min) / k1]);
u_eq(2) = max([0, R20 * (x_eq(4) - I2min) / k2]);

u_eq(1) = max([0, (R10 * x_eq(3) - c1) / k1]);
u_eq(2) = max([0, (R20 * x_eq(4) - c2) / k2]);

end

