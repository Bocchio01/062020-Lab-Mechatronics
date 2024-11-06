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

N_transients = 5;

current = cell(files_data.N_files, N_transients);
voltage = cell(files_data.N_files, N_transients);
time = cell(files_data.N_files, N_transients);

z = zeros(files_data.N_files, N_transients);
I = zeros(files_data.N_files, N_transients);
L = zeros(files_data.N_files, N_transients);

for file_idx = 1:files_data.N_files

    measurements = data(file_idx);

    % Transients search
    transient_idxs = find(abs(diff(measurements.voltage)) > 0.1);
    assert(length(transient_idxs) == 2*N_transients, ['Not enough transients found in file #' num2str(file_idx)])

    % Fitting current dynamics to compute L and R
    L_guess = 0.125; %[H]

    coefficients_guess = L_guess;

    for transient_idx = 1:N_transients

        start_idx = transient_idxs(2*transient_idx - 1);
        % final_idx = transient_idxs(2*transient_idx + 0) - 1;
        final_idx = start_idx + 60;

        current{file_idx, transient_idx} = measurements.current(start_idx+1 : final_idx+1);
        voltage{file_idx, transient_idx} = measurements.voltage(start_idx+0 : final_idx+0);
        time{file_idx, transient_idx} = measurements.time(start_idx : final_idx) - measurements.time(start_idx);

        fitted_model = fitnlm( ...
            [time{file_idx, transient_idx} voltage{file_idx, transient_idx}], current{file_idx, transient_idx}, ...
            @current_model, coefficients_guess, ...
            'Options', statset('TolFun', 1e-10));

        z(file_idx, transient_idx) = mean(measurements.position) - 0.0012;
        I(file_idx, transient_idx) = mean(current{file_idx, transient_idx}(floor(1/2 * length(current)):end));
        L(file_idx, transient_idx) = fitted_model.Coefficients.Estimate(1);

    end

end

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

% save("inductance_analysis", "LI", "aI", "Lz", "az", "L0");


%% Plots

reset(0);
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'defaultaxesfontsize', 15);

% Current dynamics fitting
figure_I = figure('Name', 'Inductance analysis');
nexttile

for file_idx = 1:files_data.N_files

    measurements = data(file_idx);

    for transient_idx = 1:N_transients

        plot3( ...
            time{file_idx, transient_idx}, ...
            z(file_idx, transient_idx) * ones(length(time{file_idx, transient_idx}), 1) * 1000, ...
            current{file_idx, transient_idx}, ...
            'k');
        
        hold on
        grid on

        % plot3( ...
        %     time{file_idx, transient_idx}, ...
        %     z(file_idx, transient_idx) * ones(200, 1) * 1000, ...
        %     current_model(L(file_idx, transient_idx), [time{file_idx, transient_idx} voltage{file_idx, transient_idx}]), ...
        %     'r')

    end

end

view([30 7])

title('Current dynamics experimental data')
xlabel('Time [s]')
ylabel('Position [mm]')
zlabel('Current [A]')
legend('Measured')


% Current dynamics fitting (visualization of a single distance test)
nexttile
hold on
grid on

for file_idx = 5

    measurements = data(file_idx);

    for transient_idx = 1:N_transients

        plot( ...
            time{file_idx, transient_idx}, ...
            current{file_idx, transient_idx}, ...
            'k');
        
        plot( ...
            time{file_idx, transient_idx}, ...
            current_model(L(file_idx, transient_idx), [time{file_idx, transient_idx} voltage{file_idx, transient_idx}]), ...
            'r', ...
            'LineWidth', 2)

    end

end


title(['Current dynamics fitting @z=' num2str(z(file_idx, 1) * 1000) 'mm'])
xlabel('Time [s]')
ylabel('Current [A]')
legend('Measured', 'Fitted')


% Inductance modelling and fitting
figure_L = figure('Name', 'Inductance modelling and fitting');
tiledlayout(1, 2)
nexttile

plot3(z * 1000, I, L, 'k*', 'LineWidth', 3)
hold on
grid on

[Z_grid, I_grid] = meshgrid(linspace(min(z(:)), max(z(:)), 30), linspace(min(I(:)), max(I(:)), 30));
surf(Z_grid * 1000, I_grid, reshape(inductance_model([L0, az, Lz, aI, LI], [Z_grid(:), I_grid(:)]), size(Z_grid)), 'EdgeColor', 'k', 'FaceAlpha', 0.8);

view([65 35])
colormap(jet);
colorbar

title('Inductance modelling L(z, I)');
xlabel('z [mm]');
ylabel('I [A]');
zlabel('L [H]');

axis tight


export_pdf_graphic(figure_I, '/measurements/currents');
export_pdf_graphic(figure_L, '/measurements/inductance');


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

L = L0 + Lz * exp(-az * z) + LI * tanh(-aI * I);
% L = L0 + Lz * exp(-az * z);

% Sanity checks for fitnlm stability
L(isinf(L)) = sign(x(isinf(L))) .* 1e100;
L(isnan(L)) = 1e100;

end