function [x_eq, u_eq] = operating_point(z_star, I2_star)

% Load system parameters
run("maglev_init.m");
[I1, I2, dI1du, dI2du, L1, L2, dL1dx, dL2dx, dL1ddx, dL2ddx] = components_equations(); %#ok<ASGLU>

if (nargin == 1)
    % Chosen in order to ignore the effect of the lower electromagnet
    I2_star = I2min;
end

x_eq = zeros(4, 1);
u_eq = zeros(2, 1);

x_eq(1) = z_star;
x_eq(2) = 0;
x_eq(4) = I2_star;
x_eq(3) = sqrt( -(2*M*g + dL2dx(x_eq(1)) * x_eq(4)^2) / dL1dx(x_eq(1)) );

u_eq(1) = max([0, (x_eq(3) - I1min) / m]);
u_eq(2) = max([0, (x_eq(4) - I2min) / m]);

end

