% clc
% clear variables
% close all

%% Get number of files to be loaded

files_data = struct( ...
    'path', 'identification\data\force', ...
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

load("parameters_lagrangian.mat", "g", "m");
% sensitivity_equation = @(current) -2*m*g ./ current.^2;
sensitivity_equation = @(current) -m*g ./ current.^2;

position_jump_idx = zeros(files_data.N_files, 1);
position = zeros(files_data.N_files, 1);
current = zeros(files_data.N_files, 1);
sensitivity = zeros(files_data.N_files, 1);

for file_idx = 1:files_data.N_files

    measurements = data(file_idx);

    position_jump_idx(file_idx) = floor(find(diff(measurements.position) < -0.5e-3, 1, 'first') - 60);
    position(file_idx) = mean(measurements.position(1:floor(0.7 * position_jump_idx(file_idx))));
    current(file_idx) = mean(measurements.current(position_jump_idx(file_idx) + (-1:1)));

    sensitivity(file_idx) = sensitivity_equation(current(file_idx));

end

% Model fitting
Lz_guess = 0.017521; %[H]
az_guess = 1 / 0.0058231; %[1/m]
coefficients_guess = [Lz_guess az_guess];

fitted_model = fitnlm( ...
    position, sensitivity, ...
    @sensitivity_inductance_model, coefficients_guess, ...
    'Options', statset('TolFun', 1e-10));

Lz = fitted_model.Coefficients.Estimate(1);
az = fitted_model.Coefficients.Estimate(2);


%% Results

fprintf([ ...
    'F(z, I) characterization (EM1):\n' ...
    '\taz:\t%d\n' ...
    '\tLz:\t%d\n' ...
    ], az, Lz);


%% Plots

reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'defaultaxesfontsize', 15);

figure_measurements = figure('Name', 'Measurements');

for file_idx = files_data.N_files:-5:1

    measurements = data(file_idx);

    nexttile
    hold on
    grid on
    colororder({'r', 'k'})

    yyaxis left
    plot(measurements.position * 1000, 'r')
    set(gca, 'YDir', 'reverse')
    ylabel('Ball position [mm]')
    ylim padded

    yyaxis right
    plot(measurements.current, 'k')
    ylabel('Current [A]')
    ylim padded

    xline(position_jump_idx(file_idx) + 40, '--k', 'LineWidth', 2, 'Label', 'Levitation')
    xlabel('# [-]')

    xlim(position_jump_idx(file_idx) + 40 + 150 * [-1 1]);

    title(['Initial position z=' num2str(mean(measurements.position(1:position_jump_idx(file_idx)-50)) * 1000, '%.2f')  '[mm]'])

end


% Inductance sensitivity function of distance
figure_dLdz = figure('Name', 'Inductance sensitivity and resulting force');
nexttile
hold on
grid on

load("parameters_lagrangian.mat", "L1z", "a1z")
load("parameters_literature.mat", "FemP1", "FemP2");
plot(position * 1000, -sensitivity, 'ko', 'DisplayName', 'Experimental data');
plot(position * 1000, -sensitivity_inductance_model([Lz az], position), 'LineWidth', 1.5, 'DisplayName', 'Experimental interpolation');
plot(position * 1000, -sensitivity_inductance_model([0.0343822800000000 183.730200000000], position), 'LineWidth', 1.5, 'DisplayName', 'Based on L(z, I) identification');
plot(position * 1000, -sensitivity_inductance_model([L1z a1z], position), 'LineWidth', 1.5, 'DisplayName', 'Based on operating point analysis');
% plot(position * 1000, -2*sensitivity_inductance_model([FemP1 1/FemP2], position), 'LineWidth', 1.5, 'DisplayName', 'Literature');
% plot(position * 1000, -sensitivity_inductance_model([0.0404474296969937 158.542264748131], position), 'LineWidth', 1.5, 'DisplayName', 'From OP');

title('Inductance sensitivity to object distance')
xlabel('Ball position [mm]')
ylabel('dL/dz [H/m]')
legend('Location', 'best')


% Inductance sensitivity function of distance and current
nexttile
hold on
grid on

[Z_grid, I_grid] = meshgrid(linspace(0, 0.030, 20), linspace(0, 2.5, 20));
plot3(position * 1000, flip(current), force_model([Lz az], [position flip(current)]), 'k*', 'LineWidth', 3)
surf(Z_grid * 1000, I_grid, reshape(force_model([Lz az], [Z_grid(:), I_grid(:)]), size(Z_grid)), 'EdgeColor', 'k', 'FaceAlpha', 0.8);

axis tight
view([65 35])
colormap(jet(64));
colorbar

title('Electromagnetic force F(z, I)')
xlabel('z [mm]')
ylabel('I [A]')
zlabel('F [N]')
legend('Experimental', 'Location', 'best')

try %#ok<TRYNC>
    % export_pdf_graphic(figure_measurements, '/identification/currents_for_force');
    % export_pdf_graphic(figure_dLdz, '/identification/force');
end



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