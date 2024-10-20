function [x_eq, u_eq] = compute_operating_point(z_star, I2_star)

% Load system parameters
run("maglev_init.m");

if (nargin == 1)
    % Chosen by chance
    I2_star = ci;
end

x_eq = zeros(4, 1);
u_eq = zeros(2, 1);

x_eq(1) = z_star;
x_eq(2) = 0;
x_eq(4) = I2_star;
x_eq(3) = sqrt( (2*m*g + x_eq(4)^2 * a2*L2z * exp(-a2 * (H - 2*r - x_eq(1)))) / (a1*L1z * exp(-a1*x_eq(1))) );

u_eq(1) = (x_eq(3) - ci) / ki;
u_eq(2) = (x_eq(4) - ci) / ki;

end

