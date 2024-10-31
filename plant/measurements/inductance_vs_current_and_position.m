clc
clear variables
close all

%% Get number of files to be loaded

electromagnet_idx = 1;
file_path = 'plant\measurements\data\inductance\';
% file_path = ['plant\measurements\data\Induttanza' num2str(electromagnet_idx)];

files_data = struct( ...
    'path', file_path, ...
    'dir_content', [], ...
    'N_files', 0);

files_data.dir_content = flip(dir([files_data.path '\' num2str(electromagnet_idx) '*.mat']));
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
    data(file_idx) = load_data([files_data.path '\' files_data.dir_content(file_idx).name], electromagnet_idx);
end

clear file_idx

%% Fitting current transient to compute L, and annotate z, I
% Once z, I and L are know, we can fit out inductance model on these data

N_transients = 10;

z = zeros(files_data.N_files, N_transients);
I = zeros(files_data.N_files, N_transients);
L = zeros(files_data.N_files, N_transients);

for file_idx = 1:files_data.N_files

    measurements = data(file_idx);

    % Transients search
    transient_idxs = find(abs(diff(measurements.voltage)) > 0.1);
    assert(length(transient_idxs) == N_transients, ['Not enough transients found in file #' num2str(file_idx)])

    % Fitting current dynamics to compute L and R
    L_guess = 0.125; %[H]

    coefficients_guess = L_guess;

    for transient_idx = 1:2:N_transients-1

        start_idx = transient_idxs(transient_idx);
        final_idx = transient_idxs(transient_idx + 1) - 1;

        current = measurements.current(start_idx+1 : final_idx+1);
        voltage = measurements.voltage(start_idx+0 : final_idx+0);
        time = measurements.time(start_idx : final_idx) - measurements.time(start_idx);

        fitted_model = fitnlm( ...
            [time voltage], current, ...
            @current_model, coefficients_guess, ...
            'Options', statset('TolFun', 1e-10));

        z(file_idx, transient_idx) = mean(measurements.position);
        I(file_idx, transient_idx) = mean(current(floor(1/2 * length(current)):end));
        L(file_idx, transient_idx) = fitted_model.Coefficients.Estimate(1);

    end

end

z = z(:, 1:2:N_transients-1);
I = I(:, 1:2:N_transients-1);
L = L(:, 1:2:N_transients-1);


%% Fitting the previously computed L over our exponential models

L0_guess = 0.125; %[H]
az_guess  = 0.055; %[1/m]
Lz_guess = 0.125; %[H]
aI_guess  = 0.055; %[1/A]
LI_guess = 0.125; %[H]

coefficients_guess = [L0_guess az_guess Lz_guess aI_guess LI_guess];

fitted_model = fitnlm( ...
    [reshape(z, 1, [])' reshape(I, 1, [])'], reshape(L, 1, [])', ...
    @inductance_model, coefficients_guess, ...
    'Options', statset('TolFun', 1e-10));

L0 = fitted_model.Coefficients.Estimate(1);
az = fitted_model.Coefficients.Estimate(2);
Lz = fitted_model.Coefficients.Estimate(3);
aI = fitted_model.Coefficients.Estimate(4);
LI = fitted_model.Coefficients.Estimate(5);


%% Results

fprintf([ ...
    'Electromagnet EM%d:\n' ...
    '\tL0:\t%d\n' ...
    '\taz:\t%d\n' ...
    '\tLz:\t%d\n' ...
    '\taI:\t%d\n' ...
    '\tLI:\t%d\n' ...
    ], electromagnet_idx, L0, az, Lz, aI, LI);

save("inductance_analysis", "LI", "aI", "Lz", "az", "L0");


%% Plots

reset(0);
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');

% Current dynamics fitting
% figure('Name', 'Current dynamics fitting')
nexttile
hold on
grid on

file_idx = 1;
measurements = data(file_idx);

for transient_idx = 1:2:N_transients-1

    start_idx = transient_idxs(transient_idx);
    final_idx = transient_idxs(transient_idx + 1) - 1;

    current = measurements.current(start_idx+1 : final_idx+1);
    voltage = measurements.voltage(start_idx+0 : final_idx+0);
    time = measurements.time(start_idx : final_idx) - measurements.time(start_idx);

    plot(time, current, '--k');
    plot(time, current_model(L(file_idx, transient_idx/2+0.5), [time voltage]), 'r')

end

title(['Current dynamics fitting (z=' num2str(z(file_idx, 1) * 1e3) '[mm])'])
xlabel('Time [s]')
ylabel('Current [A]')
legend('Measured', 'Fitted')

% Inductance modelling
% figure('Name', 'Inductance modelling L(z, I))')
nexttile

surf(z, I, L, 'FaceAlpha', 1);
hold on

z_range = linspace(min(z(:)), max(z(:)), 100);
I_range = linspace(min(I(:)), max(I(:)), length(z_range));
[Z_grid, I_grid] = meshgrid(z_range, I_range);

mesh(Z_grid, I_grid, reshape(inductance_model([L0, az, Lz, aI, LI], [Z_grid(:), I_grid(:)]), size(Z_grid)), ...
    'EdgeColor', 'k', ...
    'FaceAlpha', 0.5);

colormap(jet);

xlabel('z [mm]');
ylabel('I [A]');
zlabel('L [H]');
title('3D Surface Plot of L(z, I)');

axis tight



%% Functions

function I = current_model(b, x)

run("resistances_init.m")
electromagnet_idx = evalin("base", "electromagnet_idx");

t = x(:, 1);
V = x(:, 2);
L = b(1);
R = (electromagnet_idx == 1) * R10 + (electromagnet_idx == 2) * R20;

I = V(end) / R - (V(end) - V(1)) / R * exp(-1 * R / L * t);

% Sanity checks for fitnlm stability
I(isinf(I)) = sign(x(isinf(I))) .* 1e100;
I(isnan(I)) = 1e100;

end

function L = inductance_model(b, x)

z = x(:, 1);
I = x(:, 2);

L0 = b(1);
az = b(2);
Lz = b(3);
aI = b(4);
LI = b(5);

L = L0 + Lz * exp(-az * z) + LI * exp(-aI * I);
% L = L0 + Lz * exp(-az * z);

% Sanity checks for fitnlm stability
L(isinf(L)) = sign(x(isinf(L))) .* 1e100;
L(isnan(L)) = 1e100;

end