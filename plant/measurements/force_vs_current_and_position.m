% clc
clear variables
% close all

%% Get number of files to be loaded

files_data = struct( ...
    'path', 'plant\measurements\data\force', ...
    'dir_content', [], ...
    'N_files', 0);

files_data.dir_content = dir([files_data.path '\*.mat']);
files_data.N_files = length(files_data.dir_content);


%% Load data

data = repmat( ...
        struct( ...
            'time', [], ...
            'position', [], ...
            'velocity', [], ...
            'current', [], ...
            'control', [], ...
            'voltage', []), ...
        1, ...
        files_data.N_files);

for file_idx = 1:files_data.N_files
    data(file_idx) = load_data([files_data.path '\' files_data.dir_content(file_idx).name]);
end

clear file_idx


%% Compute dL(x)/dx @ Fem == Fg
% Basically, when the ball starts moving, that our point of interest.
% Knowing the initial position, and computing the current when the ball
% starts moving, we automatically get dL(x)/dx

g = 9.81; %[m/s^2]
m = 61.57e-3; %[Kg]
sensitivity_equation = @(current) -g * 2*m / current^2;

position = zeros(files_data.N_files, 1);
current = zeros(files_data.N_files, 1);
sensitivity = zeros(files_data.N_files, 1);

for file_idx = 1:files_data.N_files

    measurements = data(file_idx);

    position_jump_idx = floor(find(diff(measurements.position) < -1.0e-3, 1, 'first') * 0.98);

    position(file_idx) = mean(measurements.position(1:floor(0.7 * position_jump_idx)));
    current(file_idx) = measurements.current(position_jump_idx);
    sensitivity(file_idx) = sensitivity_equation(current(file_idx));

end

% Model fitting

L1_guess = 0.017521; %[H]
a_guess = 1 / 0.0058231; %[1/m]
coefficients_guess = [L1_guess a_guess];

fitted_model = fitnlm( ...
    [position], sensitivity, ...
    @sensitivity_inductance_model, coefficients_guess, ...
    'Options', statset('TolFun', 1e-10));

L1z = fitted_model.Coefficients.Estimate(1);
a = fitted_model.Coefficients.Estimate(2);

fprintf([ ...
    'Electromagnet EM1:\n' ...
    '\tInductance sensitivity to z Lz:\t%d\n' ...
    '\tInductance sensitivity parameter a:\t%d\n' ...
    ], L1z, a);


%% Plots
reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');


% for file_idx = 1:files_data.N_files
% 
%     figure
%     hold on
%     measurements = data(file_idx);
% 
%     position_jump_idx = floor(find(diff(measurements.position) < -1.0e-3, 1, 'first') * 0.98);
% 
%     plot(measurements.position)
%     plot(measurements.current)
% 
%     xline(position_jump_idx , 'r')
% 
% end


nexttile
hold on
grid on

plot(position, -sensitivity, 'ko');
plot(position, -sensitivity_inductance_model([L1z a], position), 'r');
plot(position, -sensitivity_inductance_model([2.5*L1z 1.2*a], position), 'b');


title('Inductance sensitivity to object distance dLdx')
xlabel('Distance [m]')
ylabel('dL/dx [H/m]')
legend('Measured', 'Fitted model')



nexttile

z_range = position(:);
I_range = current(:);
[Z_grid, I_grid] = meshgrid(z_range, I_range);

surf(Z_grid, I_grid, reshape(force_model([L1z a], [Z_grid(:), I_grid(:)]), size(Z_grid)), 'EdgeColor', 'k', 'FaceAlpha', 0.5);
hold on
plot3(position, flip(current), -1/2 * sensitivity_inductance_model([L1z a], position) .* flip(current.^2), 'ro', 'LineWidth', 5)

colormap(jet);

xlabel('z [mm]');
ylabel('I [A]');
zlabel('F [N]');
title('3D Surface Plot of F(z, I)');


%% Functions

function sensitivity = sensitivity_inductance_model(b, x)

z = x(:, 1);
Lz = b(1);
az = b(2);

sensitivity = -az * Lz * exp(-az * z);

% Sanity checks for fitnlm stability
sensitivity(isinf(sensitivity)) = sign(x(isinf(sensitivity))) .* 1e100;
sensitivity(isnan(sensitivity)) = 1e100;

end

function F = force_model(b, x)

z = x(:, 1);
I = x(:, 2);

Lz = b(1);
az = b(2);

F = abs(-1/2 * az * Lz * exp(-az * z) .* I.^2);

% Sanity checks for fitnlm stability
F(isinf(F)) = sign(x(isinf(F))) .* 1e100;
F(isnan(F)) = 1e100;

end