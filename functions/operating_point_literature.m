function [x_eq, u_eq] = operating_point_literature(z_star, I2_star)

% Load system parameters
load("parameters_literature.mat"); %#ok<LOAD>

if (nargin == 1)
    % Chosen in order to ignore the effect of the lower electromagnet
    I2_star = ci;
end

x_eq = zeros(4, 1);
u_eq = zeros(2, 1);

x_eq(1) = z_star;
x_eq(2) = 0;
x_eq(4) = I2_star;
x_eq(3) = sqrt( (m*g + FemP1/FemP2 * exp(-(H - 2*r - x_eq(1)) / FemP2) * x_eq(4)^2) / (FemP1/FemP2 * exp(-x_eq(1) / FemP2)) );

u_eq(1) = (x_eq(3) - ci) / ki;
u_eq(2) = (x_eq(4) - ci) / ki;

end

